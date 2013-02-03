{ Pretty-printer }
{ Ondrej Svec, I. rocnik, MMF-UK }
{ zimni semestr 2012/13 }
{ Programovani NPRG030: RNDr. Tomas Holan, Ph.D. }

program templating;
{ = $MODE DELPHI = }
uses crt;

{ oznaceni promennych v sablonach }
const variablePrefix = '{$';
const variablePostfix = '}';
{ standartni pojmenovani souboru }
const defaultOutputName = 'prettyPrinter.html';
const defaultTemplateName = 'prettyPrinterTemplate.html';
const defaultSourceName = 'prettyPrinter.pas';
{ velikost odsazeni }
const indentationSize = 4; 

{ modifikatory pro vypisovani/zkraslovani kodu }
{ uvnitr komentare }
const mComment      = 1;
{ jednoradkovy komentar }
const mCommentLine  = 2;
(* zavorkovy komentar (**)
const mCommentPar   = 4; 
{ uvnitr stringu }
const mString       = 8;
{ ve zdrojaku byl novy radek, preskoc vsechny mezery }
const mNewLine      = 16;
{ uvnitr zavorek }
const mParentheses  = 32; 
{ pred vypisovanim dalsiho slova odradkuj }
const mNewLineDelay = 64;
{ nevypisuj HTML }
const mPlain        = 128;
{ byl vytisten novy radek (pro opozdene odsazeni) }
const mLinePrinted  = 256;
{ vloz begin & end na samostatny radek }
const mAddSpecLine  = 512;
const mComments     = mComment or mCommentLine or mCommentPar;
const mSpecial      = mComments or mString;

var templateFile, outputFile : text;
var attributes : integer; { pro modifikatory }
var rowNumber : integer; { cislovani radku }
var indentation : integer; { odsazeni }
var parentheses : integer; { uzavorkovani }
var commentCharCache : char; { double-char comment fix }
var inputSourceName, outputName, templateName : string; { jmena souboru }
var z : char; { pomocna promenna }

{ seznam slov pro zvyrazneni }
var keywords : array[1..18] of string;
{ seznam slov, ktere jsou oddelene dalsim radkem }
{var newLineWords:array[1..05] of string = ('procedure', 'function', 'while', 'for', 'else');}
{ seznam datovych typu }
{var dataTypes: array[1..13] of string = ('byte', 'shortint', 'word', 'inted', 'comp', 'bool', 'boolean', 'string');}

{ funkce dec, ktera snizuje pouze do nuly }
procedure decPositive(var i : integer);
  begin
    if i <= 0 then exit;
    dec(i);
  end;

{ integer to string - pro vypisovani cisla radku }
function IntToStr (I : Longint) : string;
  var S : string;
  begin
    Str (I,S);
    IntToStr:=S;
  end;

function isLetter(c:char):boolean;
  begin
    isLetter := false;
    if c in ['a'..'z', 'A'..'Z'] then isLetter := true;
  end;

{ zkontroluje, zda-li je modifikator aktivni
 attr = cislo modifikatoru }
function attrCheck(attr : integer):boolean;
  begin
    attrCheck := true;
    if attributes and attr = 0 then attrCheck := false;
  end;

{ zapne modifikator
  attr = cislo modifikatoru }  
procedure attrEnable(attr : integer);
  begin attributes := attributes or attr; end;

{ vypne modifikator
  attr = cislo modifikatoru }
procedure attrDisable(attr : integer);
  begin attributes := attributes and not attr; end;

{ zjisti, jestli je slovo v nejakem z preddefinovanych poli
  s = hledane slovo
  arr = prohledavane pole }
function isSpecial(var s:string; var arr:array of string):boolean;
  var i : integer;
  begin
    isSpecial := false;
    for i:=low(arr) to high(arr) do
      if arr[i] = s then begin
        isSpecial := true;
        break;
      end;    
  end;

procedure outputNewLine(closeTag : boolean); forward;

{ opozdene vypisovani noveho radku
  - podle modifikatoru rozhodne, zda-li ma vytisknout novy radek }
procedure checkForNewLineDelayed;
  begin
    if attrCheck(mNewLineDelay) and not attrCheck(mComments) then
      begin
        outputNewLine(true);
        attrDisable(mNewLineDelay);
      end;
  end;

{ odsazeni vysledneho kodu
  const indentationSize = sirka odsazeni } 
procedure outputIndentation;
  var i,j : integer;
  begin
    for i:=1 to indentation do
      for j:=1 to indentationSize do
        if attrCheck(mPlain) then
          write(outputFile, ' ')
        else 
          write(outputFile, '&nbsp;')
  end;

{ vypisovani do html output 
  text = vypisovany string
  printingHTML = obsahuje text HTML? }
procedure outputLine(text : string);
  begin                               
    { pokud nechceme vypisovat HTML }
    { if printingHTML and attrCheck(mPlain) then exit; }
    
    { pokud jsme na novem radku, vypiseme odsazeni }
    if attrCheck(mLinePrinted) then outputIndentation;
    attrDisable(mLinePrinted);
    
    write(outputFile, {UTF8ToAnsi}(text));
  end;

{ novy radek ve zdrojaku HTML output } 
procedure outputEnter;
  begin
    writeln(outputFile);
  end;

{ zkratka pro vypisovani HTML }
procedure outputHTML(text : string);
  begin
    if attrCheck(mPlain) then exit;
    
    if attrCheck(mLinePrinted) then outputIndentation;
    attrDisable(mLinePrinted);
    
    write(outputFile, {UTF8ToAnsi}(text));
    
    { outputLine(text, true); }
  end;

{ vypisovani noveho radku
  closeTag = vypsat ukoncovaci HTML tagy? }
procedure outputNewLine(closeTag : boolean);
  begin
    if closeTag then
      begin
        if attrCheck(mComment) then outputHTML('</code>');
        outputHTML('</td></tr>');
      end;
    
    outputEnter;
    { cislovani radku }
    outputHTML('<tr><td class="gutter">');
    outputHTML(intToStr(rowNumber));
    outputHTML('</td><td class="code">');
    inc(rowNumber);
        
    { pro viceradkove komentare: na novem radku se komentar musi opet zapnout }
    if attrCheck(mComments) then outputHTML('<code class="comments">');

    attrEnable(mLinePrinted);
    attrDisable(mAddSpecLine);
  end;

{ vypisovani specialnich znaku
  c = vypisovany znak
  pc = predchozi znak }
procedure outputChar(c, pc : char);
  var sOut : string;
  begin

    { vypise cache pro znaky, ktere zacinaji jako komentare }
    if commentCharCache <> chr(0) then
      begin
        outputLine(commentCharCache);
        commentCharCache := chr(0);
      end;

    { KOMENTARE - slo by trohu zrefraktorovat, ale asi by se ztratila citelnost? }
    { single-line komentar }
    if (c = '/') and (pc = '/') and not attrCheck(mSpecial) then
      begin
        attrEnable(mCommentLine);
        attrDisable(mNewLineDelay);
        outputHTML('<code class="comments">');
      end;
    { multi-line komentar - slozene zavorky }
    if (c = '{') and not attrCheck(mSpecial) then
      begin
        attrEnable(mComment);
        outputHTML('<code class="comments">');
      end;
    if (c = '}') and not attrCheck(mSpecial and not mComment) then
      begin
        attrDisable(mComment);
        outputLine('}');
        outputHTML('</code>');
        if not attrCheck(mParentheses) then attrEnable(mNewLineDelay);
        exit;
      end;
    { (**) multi-line komentar - hvezdickove zavorky }
    if (c = '*') and (pc = '(') and not attrCheck(mSpecial) then
      begin
        attrEnable(mCommentPar);
        outputHTML('<code class="comments">');
      end;
    if (c = ')') and (pc = '*') and not attrCheck(mSpecial and not mCommentPar) then
      begin
        attrDisable(mCommentPar);
        outputLine(')');
        outputHTML('</code>');
        if not attrCheck(mParentheses) then attrEnable(mNewLineDelay);
        exit;
      end;

    { specialni HTML znaky -> html-entities }
    sOut := c;
    if not attrCheck(mPlain) then
      begin
        if c = '<' then sOut := '&lt;';
        if c = '>' then sOut := '&gt;';
      end;

    { single-quotes '' = strings }
    if (c = chr(39)) and not attrCheck(mComments) then
      begin
        { zacatek stringu }
        if not attrCheck(mString) then
          begin
            outputHTML('<code class="string">');
            outputLine(chr(39));
            attrEnable(mString);
          end
        else { konec stringu }
          begin
            outputLine(chr(39));
            outputHTML('</code>');
            attrDisable(mString);
          end;
        exit;
      end;

    { uzavorkovani - uvnitr zavorek se neodradkovava }
    if not attrCheck(mSpecial) then
      begin
        if c = '(' then inc(parentheses);
        if c = ')' then decPositive(parentheses);

        if parentheses > 0 then attrEnable(mParentheses)
        else attrDisable(mParentheses)
      end;

    { za strednikem odentruj }
    if c = ';' then
      if not attrCheck(mParentheses)
        and not attrCheck(mSpecial) then attrEnable(mNewLineDelay);

    { ulozi cache pro znaky, ktere zacinaji jako komentare } 
    {if attrCheck(mComments) then outputLine('$'); }         
    if (c = '(') or (c = '/') then      
      begin                                                 
        commentCharCache := c;                              
        exit;                                               
      end;                                                  
    
    { vypis znak }
    outputLine(sOut);
  end;
  
{ vypisovani/kontrola specialnich slov
  word = kontrolovane slovo }
procedure outputWord(word : string);
  begin
  
    { vypise cache pro znaky, ktere zacinaji jako komentare }
    if commentCharCache <> chr(0) then
      begin
        outputLine(commentCharCache);
        commentCharCache := chr(0);
      end;
  
    if not attrCheck(mSpecial) then
      begin
        { zvetsovani/zmensovani odsazeni pred }
        if word = 'end' then decPositive(indentation);
        if word = 'begin' then inc(indentation);
        
        { begin/end na novy radek }
        if ((word = 'end') or (word = 'begin'))
          and not attrCheck(mNewLineDelay)
          and attrCheck(mAddSpecLine) then attrEnable(mNewLineDelay);
      end;
    
    { odradkuj, pokud chces }
    checkForNewLineDelayed;
    
    { slovo neni specialni, vypis }
    if attrCheck(mSpecial) then
      begin
        outputLine(word);
        exit;
      end;

    { dalsi novy radek pred nektermi klicovymi slovy }
    {if isSpecial(word, newLineWords) then outputNewLine;}
  
    { keywords }
    if isSpecial(word, keywords) then
      begin
        outputHTML('<code class="keyword">');
        outputLine(word);
        outputHTML('</code>');
      end
    else outputLine(word);

    if not attrCheck(mSpecial) then
      begin
        { zvetsovani/zmensovani odsazeni po }
        if word = 'end' then decPositive(indentation);
        if word = 'begin' then inc(indentation);
        
        { odradkovani po begin/end }
        if ((word = 'end') or (word = 'begin'))
          and not attrCheck(mLinePrinted) then attrEnable(mNewLineDelay);
      end;
    
    attrEnable(mAddSpecLine);
  end;

{ hlavni procedura - cteni zdrojaku, vypisovani
  inputSourceName = jmeno zdrojoveho souboru [.pas]
  plainText = vypisovat HTML znacky? }
procedure runPrettyPrinter(inputSourceName : string; plainText : boolean);
  var whatFile : text;
  var c, pc : char;
  var sOut : string;
  begin
    { inicializace }
    assign(whatFile, inputSourceName);
    reset(whatFile);
    attributes := 0;
    rowNumber := 1;
    pc := chr(0);
    sOut := '';
    indentation := 0;
    
    if plainText then attrEnable(mPlain);
        
    outputHTML('<table border=0 class="prettyprinter">');
    outputNewLine(false);
    attrEnable(mNewLine);

    while not eof(whatFile) do
      begin
        read(whatFile, c);

        { preskoc vsechny mezery na zacatku radku }
        if attrCheck(mNewLine) then
          begin
            while c = ' ' do
              read(whatFile, c);
            attrDisable(mNewLine);
          end;
        
        { vytvor slovo }
        if isLetter(c) then sOut := sOut + c
        else
          begin
            if length(sOut)>0 then outputWord(sOut);
            sOut := '';
          end;
        
        { zahod vicenasobne mezery }
        if (c = ' ') and (pc = ' ') then continue;
        { zpracuj novy radek v puvodnim zdrojaku }
        if (c = chr(13)) or (c = chr(10)) then
          begin
            attrDisable(mCommentLine);
            attrDisable(mNewLineDelay);
            attrEnable(mNewLine);
            
            outputNewLine(true);

            if c = chr(13) then read(whatFile, c); { discard CRLF }
            continue; { netiskni znovu novy radek }
          end;
        
        if not isLetter(c) then outputChar(c, pc);
        pc := c;
      
      end;
  
    outputHTML('</td></tr></table>');
    close(whatFile);  
  end;

{ nahrazeni promennych v sablone
  - promenna $output vypise HTML zdrojak }
procedure varReplaceAndPrint(line : string);
  var posPref : integer;
  var posPost : integer;
  var i : integer;
  var variableName : string;
  begin

    { hledani promennych }
    posPref := pos(variablePrefix, line);
    posPost := pos(variablePostfix, line);
    
    { promenna nenalezena }
    if (posPref = 0) or (posPost = 0) or (posPref > posPost) then 
      begin
        outputLine(line);
        outputEnter;
        exit;
      end;
    
    { vypis zacatek radku (pred promennou) }
    for i := 1 to posPref-1 do
      outputLine(line[i]);
    
    variableName := '';
    for i := posPref+length(VariablePrefix) to posPost-length(VariablePostFix) do
      variableName := variableName + line[i];
      
    { skromny vycet vsech moznych promennych v sablone }
    if 'output' = variableName then
      runPrettyPrinter(inputSourceName, false)
    else
      runError(777);
    
    { vypis zbytek radku }  
    for i := posPost+1 to length(line) do
      outputLine(line[i]);
    
    outputEnter;
  end;

{ pouziti sablony pro vypis HTML kodu }
procedure outputTemplate(outputName : string; templateName : string);
  var line : string;
  begin
    assign(templateFile, templateName);
    reset(templateFile);
    assign(outputFile, outputName);
    rewrite(outputFile);
  
    while not eof(templateFile) do
      begin
        readln(templateFile, line);
        { nahrazeni promennych v sablone }
        varReplaceAndPrint(line);
      end;
  
    close(templateFile);
    close(outputFile);  
  end;

begin
  keywords[1] := 'uses';
  keywords[2] := 'var';
  keywords[3] := 'const';
  keywords[4] := 'type';
  keywords[5] := 'begin';
  keywords[6] := 'end';
  keywords[7] := 'while';
  keywords[8] := 'for';
  keywords[9] := 'do';
  keywords[10] := 'not';
  keywords[11] := 'function';
  keywords[12] := 'procedure';
  keywords[13] := 'if';
  keywords[14] := 'then';
  keywords[15] := 'array';
  keywords[16] := 'of';
  keywords[17] := 'else';
  keywords[18] := 'program';

{ Ondrej Svec, I. rocnik, MMF-UK }
{ zimni semestr 2012/13 }
{ Programovani NPRG030 }
  writeln('Pretty-printer 1.0');
  writeln('Ondrej Svec, I. rocnik, MMF-UK');
  writeln('Zimni semestr 2012/13');
  writeln('Programovani NPRG030: RNDr. Tomas Holan, Ph.D.');
  writeln;
  writeln('===');
  writeln('Nasledujici parametry jsou nepovinne, staci odentrovat.');
  writeln('Jmeno vstupniho souboru (*.pas) [default = ',defaultSourceName,']:');
  readln(inputSourceName);
  writeln('Jmeno vystupniho souboru [default = ',defaultOutputName,']:');
  readln(outputName);
  writeln('Jmeno HTML sablony [default = ',defaultTemplateName,']:');
  readln(templateName);
  writeln('Vygenerovat i soubor bez HTML znacek? [default = N] (Y/N)');
  z := readkey;

  if length(inputSourceName) = 0 then inputSourceName := defaultSourceName;
  if length(outputName)      = 0 then outputName := defaultOutputName;
  if length(templateName)    = 0 then templateName := defaultTemplateName;

  outputTemplate(outputName, templateName);
  
  if z in ['y','Y'] then
    begin
      assign(outputFile, outputName+'.txt');
      rewrite(outputFile);
      runPrettyPrinter(inputSourceName, true);
      close(outputFile);
    end;
end.