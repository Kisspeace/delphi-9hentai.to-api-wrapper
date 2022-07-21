//♡2022 by Kisspeace. https://github.com/kisspeace
unit NineHentaito.APITypes;

interface
uses
  SysUtils, System.Generics.Collections, XSuperObject;

const
  NINEHENTAI_API = 'https://9hentai.to/api';

  // Book sort consts
  BOOK_SORT_NEWEST      = 0;
  BOOK_SORT_POPULAR     = 1;
  BOOK_SORT_MOST_FAPPED = 2;
  BOOK_SORT_MOST_VIEWED = 3;
  BOOK_SORT_BYTITLE     = 4;

  // Tag sort consts
  TAG_SORT_NAME      = 0;
  TAG_SORT_MOST_USES = 1;
  TAG_SORT_LESS_USES = 2;

  // Tag types
  TAG_TAG       = 1;
  TAG_GROUP     = 2;
  TAG_PARODY    = 3;
  TAG_ARTIST    = 4;
  TAG_CHARACTER = 5;

type

  T9HentaiBook = class;
  T9HentaiBookObjList = TObjectList<T9HentaiBook>;
  T9HentaiBookAr = TArray<T9HentaiBook>;

//  T9HentaiPivot = record
//    [ALIAS('book_id')] BookId: int64;
//    [ALIAS('tag_id')] TagId: int64;
//  end;

  T9HentaiTag = record
    [ALIAS('id')] Id: int64;
    [ALIAS('name')] Name: string;
    [ALIAS('description')] Description: string; // null ?
    [ALIAS('type')] Typ: integer;
    //[ALIAS('pivot')] Pivot: T9HentaiPivot;
  end;

  T9HentaiTagAr = TArray<T9HentaiTag>;

  T9HentaiBook = Class(TObject)
    public
      [ALIAS('id')] Id: int64;
      [ALIAS('title')] Title: string;
      [ALIAS('alt_title')] AltTitle: string;
      [ALIAS('total_page')] TotalPage: integer;
      [ALIAS('total_favorite')] TotalFavorite: integer;
      [ALIAS('total_download')] TotalDownload: integer;
      [ALIAS('total_view')] TotalView: integer;
      [ALIAS('image_server')] ImageServer: string;
      [ALIAS('tags')] Tags: TArray<T9HentaiTag>;
      function GetCoverUrl: string;
      function GetSmallCoverUrl: string;
      function GetImageUrl(AIndex: integer): string;
      function GetImageThumbUrl(AIndex: integer): string;
      Constructor Create;
  end;

  T9HentaiBookSearchRec = record
    private type
      T9HentaiBookSearchRecPages = record
        [ALIAS('range')] Range: TArray<Integer>;
      end;
    private type
      T9HentaiBookSearchRecItems = record
        [ALIAS('included')] Included: T9HentaiTagAr;
        [ALIAS('excluded')] Excluded: T9HentaiTagAr;
      end;
    private type
      T9HentaiBookSearchRecTag = record
        [ALIAS('text')] Text: string;
        [ALIAS('type')] Typ: integer;
        [ALIAS('tags')] Tags: T9HentaiTagAr;
        [ALIAS('items')] Items: T9HentaiBookSearchRecItems;
      end;
    public
      [ALIAS('text')] Text: string;
      [ALIAS('page')] Page: integer;
      [ALIAS('sort')] Sort: integer;
      [ALIAS('pages')] Pages: T9HentaiBookSearchRecPages;
      [ALIAS('tag')] Tag: T9HentaiBookSearchRecTag;
      procedure AddIncludedTag(ATag: T9HentaiTag);
      procedure AddExcludedTag(ATag: T9HentaiTag);
      constructor Create(ASearchText: string; APage: integer = 0);
      class function New: T9HentaiBookSearchRec; static;
  end;

  T9HentaiTagSearchReq = record
    private type
      T9HentaiTagSearcRec = record
        [ALIAS('text')] Text: string;
        [ALIAS('page')] Page: integer;
        [ALIAS('letter')] letter: string; // char ?
        [ALIAS('sort')] Sort: integer;
        [ALIAS('uses')] Use: integer;
      end;
    public
      [ALIAS('search')] Search: T9HentaiTagSearcRec;
      [ALIAS('type')] Typ: integer;
      constructor Create(ASearchText: string; AType: integer = TAG_TAG; APage: integer = 0);
      class function New: T9HentaiTagSearchReq; static;
  end;

implementation

{ T9HentaiBook }

constructor T9HentaiBook.Create;
begin
  Self.Id := -1;
//  Self.Title := '';
//  Self.AltTitle := '';
//  Self.TotalPage := 0;
//  Self.TotalFavorite := 0;
//  Self.TotalDownload := 0;
//  Self.TotalView := 0;
//  Self.ImageServer := '';
//  self.Tags := [];
end;

function T9HentaiBook.GetCoverUrl: string;
begin
  Result := ImageServer + Id.ToString + '/cover.jpg';
end;

function T9HentaiBook.GetImageThumbUrl(AIndex: integer): string;
begin
  Result := ImageServer + Id.ToString + '/preview/' + AIndex.ToString + 't.jpg';
end;

function T9HentaiBook.GetImageUrl(AIndex: integer): string;
begin
  Result := ImageServer + Id.ToString + '/' + AIndex.ToString + '.jpg';
end;

function T9HentaiBook.GetSmallCoverUrl: string;
begin
  Result := ImageServer + Id.ToString + '/cover-small.jpg';
end;

{ T9HentaiBookSearchRec }

procedure IncludeTagToArray(var AAr: T9HentaiTagAr; const ATag: T9HentaiTag);
var
  L: integer;
begin
  L := length(AAr);
  SetLength(AAr, L + 1);
  AAr[L] := ATag;
end;

procedure DeleteTagFromAr(var AAr: T9HentaiTagAr; const ATagId: int64);
var
  I: integer;
begin
  for I := 0 to High(AAr) do begin
    if ( AAr[I].Id = ATagId ) then begin
      if not ( I = High(AAr) ) then
        AAr[I] := AAr[High(AAr)];
      SetLength(AAr, Length(AAr) - 1);
      exit;
    end;
  end;
end;

procedure T9HentaiBookSearchRec.AddExcludedTag(ATag: T9HentaiTag);
begin
  IncludeTagToArray(Tag.Items.Excluded, ATag);
  DeleteTagFromAr(Tag.Items.Included, ATag.Id);
end;

procedure T9HentaiBookSearchRec.AddIncludedTag(ATag: T9HentaiTag);
begin
  IncludeTagToArray(Tag.Items.Included, ATag);
  DeleteTagFromAr(Tag.Items.Excluded, ATag.Id);
end;

constructor T9HentaiBookSearchRec.Create(ASearchText: string; APage: integer);
begin
  Text := ASearchText;
  Page := APage;
  Sort := BOOK_SORT_NEWEST;
  Pages.Range := [ 0, 2000 ]; // default values;
  Tag.Text := '';
  Tag.Typ := 0;
  Tag.Tags := nil;
  Tag.Items.Included := nil;
  Tag.Items.Excluded := nil;
end;

class function T9HentaiBookSearchRec.New: T9HentaiBookSearchRec;
begin
  Result := T9HentaiBookSearchRec.Create('', 0);
end;

{ T9HentaiTagSearchReq }

constructor T9HentaiTagSearchReq.Create(ASearchText: string; AType: integer; APage: integer);
begin
  Search.Text := ASearchText;
  Search.Page := APage;
  Search.letter := '';
  Search.Sort := TAG_SORT_NAME;
  Search.Use := 1;
  Typ := AType;
end;

class function T9HentaiTagSearchReq.New: T9HentaiTagSearchReq;
begin
  Result := T9HentaiTagSearchReq.Create('', 0, 0);
end;

end.
