program NinehentaiTo_test;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, net.HttpClient, net.HttpClientComponent, XSuperObject,
  Speedometer,
  Ninehentaito.APITypes in '../source/Ninehentaito.APITypes.pas',
  Ninehentaito.API in '../source/Ninehentaito.API.pas';

var
  PrintObjects: boolean = false;
  PrintJsonIdent: boolean = true;
  Nhentai: T9HentaiClient;
  Manga: T9HentaiBookObjList;
  Book: T9HentaiBook;
  id: int64;
  Tag: T9HentaiTag;
  Tags: T9HentaiTagAr;

procedure WriteTest(ATestName: string);
var
  StatusStr: string;
begin

  if Nhentai.APIStatus then
    StatusStr := 'OK'
  else
    StatusStr := 'BAD!!';

  Write(ATestName + ': ' + StatusStr);

  if not NHentai.APIMessage.IsEmpty then
    Write(' Message: ' + Nhentai.APIMessage);

  Write(SLineBreak);
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Nhentai := T9HentaiClient.Create;
    Manga := T9HentaiBookObjList.Create;

    Manga.AddRange(Nhentai.GetBook('', 0, BOOK_SORT_NEWEST));
    WriteTest('GetBook');
    if PrintObjects then
      Writeln(TJson.Stringify<T9HentaiBookAr>(Manga.ToArray, PrintJsonIdent));
    Id := Manga.First.Id;
    Manga.Clear;

    Book := NHentai.GetBookById(Id);
    WriteTest('GetBookById');
    if PrintObjects then
      Writeln(Book.AsJSON(PrintJsonIdent));
    writeln(Book.GetCoverUrl);
    writeln(Book.GetImageThumbUrl(2));
    writeln(Book.GetImageUrl(6));
    readln;

    Manga.AddRange(Nhentai.GetRelatedBooks(Id));
    WriteTest('GetRelatedBooks');
    if PrintObjects then
      Writeln(TJson.Stringify<T9HentaiBookAr>(Manga.ToArray, PrintJsonIdent));

    Tags := Nhentai.GetTags('', 0, TAG_SORT_NAME, TAG_TAG);
    WriteTest('GetTags');
    if PrintObjects then
      Writeln(TJson.Stringify<T9HentaiTagAr>(Tags, PrintJsonIdent));
    Id := Tags[0].Id;

    Tag := Nhentai.GetTagById(Id);
    WriteTest('GetTagById');
    if PrintObjects then
      Writeln(TJson.Stringify<T9HentaiTag>(Tag, PrintJsonIdent));

    
    Writeln('fin.');
    Readln;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;
end.
