function WordCreateTable(actx_word_p,data_cell_p,enter_p,varargin)
%Add a table which auto fits cell's size to contents
[nr_rows_p,nr_cols_p]=size(data_cell_p);
if(enter_p(1))
    actx_word_p.Selection.TypeParagraph; %enter
end
%create the table
%Add = handle Add(handle, handle, int32, int32, Variant(Optional))
actx_word_p.ActiveDocument.Tables.Add(actx_word_p.Selection.Range,nr_rows_p,nr_cols_p,1,1);
%Hard-coded optionals
%first 1 same as DefaultTableBehavior:=wdWord9TableBehavior
%last  1 same as AutoFitBehavior:= wdAutoFitContent
if nargin-3 >= 1
    Pace = varargin{2};
    Start = varargin{1};
    NewPace = Pace/nr_rows_p;
end
%write the data into the table
for r=1:nr_rows_p
    for c=1:nr_cols_p
        %write data into current cell
        WordText(actx_word_p,data_cell_p{r,c},'Normal',[0,0]);
        
        if(r*c==nr_rows_p*nr_cols_p)
            %we are done, leave the table
            actx_word_p.Selection.MoveDown;
        else%move on to next cell
            actx_word_p.Selection.MoveRight;
        end
    end
    if nargin-3 >= 1, waitbar(Start + r*NewPace); end
end
end