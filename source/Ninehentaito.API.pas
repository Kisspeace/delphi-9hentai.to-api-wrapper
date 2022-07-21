//♡2022 by Kisspeace. https://github.com/kisspeace
unit NineHentaito.API;

interface
uses
  SysUtils, Types, classes, XSuperObject,
  System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.Mime,
  NineHentaito.APITypes;

type

  T9HentaiClient = Class(TObject)
    private
      FAPIStatus: boolean;
      FAPIMessage: string;
      procedure ParseAPIMsg(var A: ISuperObject);
    public
      WebClient: TNetHttpClient;
      function GetBook(const ASearch: T9HentaiBookSearchRec): T9HentaiBookAr; overload;
      function GetBook(ASearchReq: string = ''; APage: integer = 0; ASort: integer = BOOK_SORT_NEWEST): T9HentaiBookAr; overload;
      function GetBookById(ABookId: int64): T9HentaiBook;
      function GetRelatedBooks(ABookId: int64): T9HentaiBookAr; overload;
      function GetTags(const ASearch: T9HentaiTagSearchReq): T9HentaiTagAr; overload;
      function GetTags(ASearchReq: string = ''; APage: integer = 0; ASort: integer = TAG_SORT_NAME; AType: integer = TAG_TAG): T9HentaiTagAr; overload;
      function GetTagById(ATagId: int64): T9HentaiTag;
      property APIStatus: boolean read FAPIStatus;
      property APIMessage: string read FAPIMessage;
      constructor Create;
      destructor Destroy;
  end;

implementation

{ T9HentaiClient }

constructor T9HentaiClient.create;
begin
  WebClient := TNetHttpClient.Create(nil);
  with ( WebClient ) do begin
    UserAgent := 'Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0';
    AutomaticDecompression := [THttpCompressionMethod.Any];
    CustomHeaders['Accept'] := 'application/json, text/plain, */*';
    CustomHeaders['Content-Type'] := 'application/json;charset=utf-8';
    CustomHeaders['Accept-Language'] := 'en-US,en;q=0.5';
    CustomHeaders['Accept-Encoding'] := 'gzip, deflate';
  end;
end;

destructor T9HentaiClient.destroy;
begin
  WebClient.Free;
end;

function T9HentaiClient.GetBook(ASearchReq: string; APage,
  ASort: integer): T9HentaiBookAr;
var
  Req: T9HentaiBookSearchRec;
begin
  Req := T9HentaiBookSearchRec.Create(ASearchReq, APage);
  Req.Sort := ASort;
  Result := Self.GetBook(Req);
end;

function T9HentaiClient.GetBook(
  const ASearch: T9HentaiBookSearchRec): T9HentaiBookAr;
var
  Data: TStringStream;
  Content: string;
  J: ISuperObject;
begin
  Result := nil;
  Data := TStringStream.Create('{"search":' + TJson.Stringify<T9HentaiBookSearchRec>(ASearch) + '}');
  try
    Content := WebClient.Post(NINEHENTAI_API + '/getBook', Data).ContentAsString;
    J := SO(Content);
    Self.ParseAPIMsg(J);
    if J.Contains('results') then
      Result := TJson.Parse<T9HentaiBookAr>(J.A['results']);
  finally
    Data.Free;
  end;
end;

function T9HentaiClient.GetBookById(ABookId: int64): T9HentaiBook;
var
  Data: TStringStream;
  Content: string;
  J: ISuperObject;
begin
  Result := nil;
  Data := TStringStream.Create('{"id":' + ABookId.ToString + '}');
  try
    Content := WebClient.Post(NINEHENTAI_API + '/getBookByID', Data).ContentAsString;
    J := SO(Content);
    Self.ParseAPIMsg(J);
    if J.Contains('results') then
      Result := T9HentaiBook.FromJSON(J.O['results']);
  finally
    Data.Free;
  end;
end;

function T9HentaiClient.GetRelatedBooks(ABookId: int64): T9HentaiBookAr;
var
  Data: TStringStream;
  Content: string;
  J: ISuperObject;
begin
  Result := nil;
  Data := TStringStream.Create('{"id":' + ABookId.ToString + '}');
  try
    Content := WebClient.Post(NINEHENTAI_API + '/getBookRelated', Data).ContentAsString;
    J := SO(Content);
    Self.ParseAPIMsg(J);
    if J.Contains('results') then
      Result := TJson.Parse<T9HentaiBookAr>(J.A['results']);
  finally
    Data.Free;
  end;
end;

function T9HentaiClient.GetTags(ASearchReq: string; APage,
  ASort: integer; AType: integer): T9HentaiTagAr;
var
  Req: T9HentaiTagSearchReq;
begin
  Req := T9HentaiTagSearchReq.Create(ASearchReq, AType, APage);
  Req.Search.Sort := ASort;
  Result := Self.GetTags(Req);
end;

function T9HentaiClient.GetTags(
  const ASearch: T9HentaiTagSearchReq): T9HentaiTagAr;
var
  Data: TStringStream;
  Content: string;
  J: ISuperObject;
begin
  Result := nil;
  Data := TStringStream.Create(TJson.Stringify<T9HentaiTagSearchReq>(ASearch));
  try
    Content := WebClient.Post(NINEHENTAI_API + '/getTags', Data).ContentAsString;
    J := SO(Content);
    Self.ParseAPIMsg(J);
    if J.Contains('results') then
      Result := TJson.Parse<T9HentaiTagAr>(J.A['results']);
  finally
    Data.Free;
  end;
end;

function T9HentaiClient.GetTagById(ATagId: int64): T9HentaiTag;
var
  Data: TStringStream;
  Content: string;
  J: ISuperObject;
begin
  Data := TStringStream.Create('{"id":' + ATagId.ToString + '}');
  try
    Content := WebClient.Post(NINEHENTAI_API + '/getTagByID', Data).ContentAsString;
    J := SO(Content);
    Self.ParseAPIMsg(J);
    if J.Contains('results') then
      Result := TJson.Parse<T9HentaiTag>(J.O['results']);
  finally
    Data.Free;
  end;
end;

procedure T9HentaiClient.ParseAPIMsg(var A: ISuperObject);
begin
  if A.Contains('status') then
    FAPIStatus := A.B['status'];

  if A.Contains('message') then
    FAPIMessage := A.S['message']
  else
    FAPIMessage := '';
end;

end.
