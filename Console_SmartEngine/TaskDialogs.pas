unit TaskDialogs;


interface
{ TTaskDialog }
uses Classes, Windows, Messages, Graphics,
     SysUtils, Consts, Dialogs, Themes,
     Forms,ActiveX;
const
  STaskDlgButtonCaption = 'Button%d';
  STaskDlgRadioButtonCaption = 'RadioButton%d';
  SInvalidTaskDlgButtonCaption = 'Caption cannot be empty';

type
  {$EXTERNALSYM tagINITCOMMONCONTROLSEX}
  tagINITCOMMONCONTROLSEX = packed record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
  end;
  PInitCommonControlsEx = ^TInitCommonControlsEx;
  TInitCommonControlsEx = tagINITCOMMONCONTROLSEX;

const
  tdiNone = 0;
  tdiWarning = 1;
  tdiError = 2;
  tdiInformation = 3;
  tdiShield = 4;


// ===================== Task Dialog =========================


// *** The Task Dialog declarations require Windows >= Vista ***


type
  { $EXTERNALSYM PFTASKDIALOGCALLBACK}
  PFTASKDIALOGCALLBACK = function(hwnd: HWND; msg: UINT; wParam: WPARAM;
    lParam: LPARAM; lpRefData: LONGInt): HResult; stdcall;
  TFTaskDialogCallback = PFTASKDIALOGCALLBACK;
    // Used for calling DisableTaskWindows and EnableTaskWindows
{$IF DEFINED(CLR)}
  TTaskWindowList = TObject;
{$ELSE}
  TTaskWindowList = Pointer;
{$IFEND}
{$IF DEFINED(CLR)}
  TFocusState = type Integer;
{$ELSE}
  TFocusState = type Pointer;
{$IFEND}

    EPlatformVersionException = class(Exception);


const    SWindowsVistaRequired = '%s requires Windows Vista or later';
  SXPThemesRequired = '%s requires themes to be enabled';
  { Task Dialog Flags }
  { For Windows >= XP }
  {$EXTERNALSYM PBS_MARQUEE}
  PBS_MARQUEE             = $08;
  {$EXTERNALSYM PBM_SETMARQUEE}
  PBM_SETMARQUEE          = WM_USER+10;

  { For Windows >= Vista }
  {$EXTERNALSYM PBS_SMOOTHREVERSE}
  PBS_SMOOTHREVERSE       = $10;

  { For Windows >= Vista }
  {$EXTERNALSYM PBM_GETSTEP}
  PBM_GETSTEP             = WM_USER+13;
  {$EXTERNALSYM PBM_GETBKCOLOR}
  PBM_GETBKCOLOR          = WM_USER+14;
  {$EXTERNALSYM PBM_GETBARCOLOR}
  PBM_GETBARCOLOR         = WM_USER+15;
  {$EXTERNALSYM PBM_SETSTATE}
  PBM_SETSTATE            = WM_USER+16;  { wParam = PBST_[State] (NORMAL, ERROR, PAUSED) }
  {$EXTERNALSYM PBM_GETSTATE}
  PBM_GETSTATE            = WM_USER+17;

  { For Windows >= Vista }
  {$EXTERNALSYM PBST_NORMAL}
  PBST_NORMAL             = $0001;
  {$EXTERNALSYM PBST_ERROR}
  PBST_ERROR              = $0002;
  {$EXTERNALSYM PBST_PAUSED}
  PBST_PAUSED             = $0003;

  {$EXTERNALSYM TDF_ENABLE_HYPERLINKS}
  TDF_ENABLE_HYPERLINKS               = $0001;
  {$EXTERNALSYM TDF_USE_HICON_MAIN}
  TDF_USE_HICON_MAIN                  = $0002;
  {$EXTERNALSYM TDF_USE_HICON_FOOTER}
  TDF_USE_HICON_FOOTER                = $0004;
  {$EXTERNALSYM TDF_ALLOW_DIALOG_CANCELLATION}
  TDF_ALLOW_DIALOG_CANCELLATION       = $0008;
  {$EXTERNALSYM TDF_USE_COMMAND_LINKS}
  TDF_USE_COMMAND_LINKS               = $0010;
  {$EXTERNALSYM TDF_USE_COMMAND_LINKS_NO_ICON}
  TDF_USE_COMMAND_LINKS_NO_ICON       = $0020;
  {$EXTERNALSYM TDF_EXPAND_FOOTER_AREA}
  TDF_EXPAND_FOOTER_AREA              = $0040;
  {$EXTERNALSYM TDF_EXPANDED_BY_DEFAULT}
  TDF_EXPANDED_BY_DEFAULT             = $0080;
  {$EXTERNALSYM TDF_VERIFICATION_FLAG_CHECKED}
  TDF_VERIFICATION_FLAG_CHECKED       = $0100;
  {$EXTERNALSYM TDF_SHOW_PROGRESS_BAR}
  TDF_SHOW_PROGRESS_BAR               = $0200;
  {$EXTERNALSYM TDF_SHOW_MARQUEE_PROGRESS_BAR}
  TDF_SHOW_MARQUEE_PROGRESS_BAR       = $0400;
  {$EXTERNALSYM TDF_CALLBACK_TIMER}
  TDF_CALLBACK_TIMER                  = $0800;
  {$EXTERNALSYM TDF_POSITION_RELATIVE_TO_WINDOW}
  TDF_POSITION_RELATIVE_TO_WINDOW     = $1000;
  {$EXTERNALSYM TDF_RTL_LAYOUT}
  TDF_RTL_LAYOUT                      = $2000;
  {$EXTERNALSYM TDF_NO_DEFAULT_RADIO_BUTTON}
  TDF_NO_DEFAULT_RADIO_BUTTON         = $4000;
  {$EXTERNALSYM TDF_CAN_BE_MINIMIZED}
  TDF_CAN_BE_MINIMIZED                = $8000;

  { Task Dialog Messages }

  {$EXTERNALSYM TDM_NAVIGATE_PAGE}
  TDM_NAVIGATE_PAGE                   = WM_USER+101;
  {$EXTERNALSYM TDM_CLICK_BUTTON}
  TDM_CLICK_BUTTON                    = WM_USER+102; // wParam = Button ID
  {$EXTERNALSYM TDM_SET_MARQUEE_PROGRESS_BAR}
  TDM_SET_MARQUEE_PROGRESS_BAR        = WM_USER+103; // wParam = 0 (nonMarque) wParam != 0 (Marquee)
  {$EXTERNALSYM TDM_SET_PROGRESS_BAR_STATE}
  TDM_SET_PROGRESS_BAR_STATE          = WM_USER+104; // wParam = new progress state
  {$EXTERNALSYM TDM_SET_PROGRESS_BAR_RANGE}
  TDM_SET_PROGRESS_BAR_RANGE          = WM_USER+105; // lParam = MAKELPARAM(nMinRange, nMaxRange)
  {$EXTERNALSYM TDM_SET_PROGRESS_BAR_POS}
  TDM_SET_PROGRESS_BAR_POS            = WM_USER+106; // wParam = new position
  {$EXTERNALSYM TDM_SET_PROGRESS_BAR_MARQUEE}
  TDM_SET_PROGRESS_BAR_MARQUEE        = WM_USER+107; // wParam = 0 (stop marquee), wParam != 0 (start marquee), lparam = speed (milliseconds between repaints)
  {$EXTERNALSYM TDM_SET_ELEMENT_TEXT}
  TDM_SET_ELEMENT_TEXT                = WM_USER+108; // wParam = element (TASKDIALOG_ELEMENTS), lParam = new element text (LPCWSTR)
  {$EXTERNALSYM TDM_CLICK_RADIO_BUTTON}
  TDM_CLICK_RADIO_BUTTON              = WM_USER+110; // wParam = Radio Button ID
  {$EXTERNALSYM TDM_ENABLE_BUTTON}
  TDM_ENABLE_BUTTON                   = WM_USER+111; // lParam = 0 (disable), lParam != 0 (enable), wParam = Button ID
  {$EXTERNALSYM TDM_ENABLE_RADIO_BUTTON}
  TDM_ENABLE_RADIO_BUTTON             = WM_USER+112; // lParam = 0 (disable), lParam != 0 (enable), wParam = Radio Button ID
  {$EXTERNALSYM TDM_CLICK_VERIFICATION}
  TDM_CLICK_VERIFICATION              = WM_USER+113; // wParam = 0 (unchecked), 1 (checked), lParam = 1 (set key focus)
  {$EXTERNALSYM TDM_UPDATE_ELEMENT_TEXT}
  TDM_UPDATE_ELEMENT_TEXT             = WM_USER+114; // wParam = element (TASKDIALOG_ELEMENTS), lParam = new element text (LPCWSTR)
  {$EXTERNALSYM TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE}
  TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE = WM_USER+115; // wParam = Button ID, lParam = 0 (elevation not required), lParam != 0 (elevation required)
  {$EXTERNALSYM TDM_UPDATE_ICON}
  TDM_UPDATE_ICON                     = WM_USER+116; // wParam = icon element (TASKDIALOG_ICON_ELEMENTS), lParam = new icon (hIcon if TDF_USE_HICON_* was set, PCWSTR otherwise)

  { Task Dialog Notifications }

  {$EXTERNALSYM TDN_CREATED}
  TDN_CREATED                = 0;
  {$EXTERNALSYM TDN_NAVIGATED}
  TDN_NAVIGATED              = 1;
  {$EXTERNALSYM TDN_BUTTON_CLICKED}
  TDN_BUTTON_CLICKED         = 2;            // wParam = Button ID
  {$EXTERNALSYM TDN_HYPERLINK_CLICKED}
  TDN_HYPERLINK_CLICKED      = 3;            // lParam = (LPCWSTR)pszHREF
  {$EXTERNALSYM TDN_TIMER}
  TDN_TIMER                  = 4;            // wParam = Milliseconds since dialog created or timer reset
  {$EXTERNALSYM TDN_DESTROYED}
  TDN_DESTROYED              = 5;
  {$EXTERNALSYM TDN_RADIO_BUTTON_CLICKED}
  TDN_RADIO_BUTTON_CLICKED   = 6;            // wParam = Radio Button ID
  {$EXTERNALSYM TDN_DIALOG_CONSTRUCTED}
  TDN_DIALOG_CONSTRUCTED     = 7;
  {$EXTERNALSYM TDN_VERIFICATION_CLICKED}
  TDN_VERIFICATION_CLICKED   = 8;            // wParam = 1 if checkbox checked, 0 if not, lParam is unused and always 0
  {$EXTERNALSYM TDN_HELP}
  TDN_HELP                   = 9;
  {$EXTERNALSYM TDN_EXPANDO_BUTTON_CLICKED}
  TDN_EXPANDO_BUTTON_CLICKED = 10;           // wParam = 0 (dialog is now collapsed), wParam != 0 (dialog is now expanded)

type
  { $EXTERNALSYM TASKDIALOG_BUTTON}
  TASKDIALOG_BUTTON = packed record
    nButtonID: Integer;
    pszButtonText: LPCWSTR;
  end;
  { $EXTERNALSYM _TASKDIALOG_BUTTON}
  _TASKDIALOG_BUTTON = TASKDIALOG_BUTTON;
  PTaskDialogButton = ^TTaskDialogButton;
  TTaskDialogButton = TASKDIALOG_BUTTON;

const
  { Task Dialog Elements }

  {$EXTERNALSYM TDE_CONTENT}
  TDE_CONTENT              = 0;
  {$EXTERNALSYM TDE_EXPANDED_INFORMATION}
  TDE_EXPANDED_INFORMATION = 1;
  {$EXTERNALSYM TDE_FOOTER}
  TDE_FOOTER               = 2;
  {$EXTERNALSYM TDE_MAIN_INSTRUCTION}
  TDE_MAIN_INSTRUCTION     = 3;

  { Task Dialog Icon Elements }

  {$EXTERNALSYM TDIE_ICON_MAIN}
  TDIE_ICON_MAIN           = 0;
  {$EXTERNALSYM TDIE_ICON_FOOTER}
  TDIE_ICON_FOOTER         = 1;

  { Task Dialog Common Icons }

  {$EXTERNALSYM TD_WARNING_ICON}
  TD_WARNING_ICON         = MAKEINTRESOURCEW(Word(-1));
  {$EXTERNALSYM TD_ERROR_ICON}
  TD_ERROR_ICON           = MAKEINTRESOURCEW(Word(-2));
  {$EXTERNALSYM TD_INFORMATION_ICON}
  TD_INFORMATION_ICON     = MAKEINTRESOURCEW(Word(-3));
  {$EXTERNALSYM TD_SHIELD_ICON}
  TD_SHIELD_ICON          = MAKEINTRESOURCEW(Word(-4));

  { Task Dialog Button Flags }

  {$EXTERNALSYM TDCBF_OK_BUTTON}
  TDCBF_OK_BUTTON            = $0001;  // selected control return value IDOK
  {$EXTERNALSYM TDCBF_YES_BUTTON}
  TDCBF_YES_BUTTON           = $0002;  // selected control return value IDYES
  {$EXTERNALSYM TDCBF_NO_BUTTON}
  TDCBF_NO_BUTTON            = $0004;  // selected control return value IDNO
  {$EXTERNALSYM TDCBF_CANCEL_BUTTON}
  TDCBF_CANCEL_BUTTON        = $0008;  // selected control return value IDCANCEL
  {$EXTERNALSYM TDCBF_RETRY_BUTTON}
  TDCBF_RETRY_BUTTON         = $0010;  // selected control return value IDRETRY
  {$EXTERNALSYM TDCBF_CLOSE_BUTTON}
  TDCBF_CLOSE_BUTTON         = $0020;  // selected control return value IDCLOSE

type
  { $EXTERNALSYM TASKDIALOGCONFIG}
  TASKDIALOGCONFIG = packed record
    cbSize: UINT;
    hwndParent: HWND;
    hInstance: HINST;                     // used for MAKEINTRESOURCE() strings
    dwFlags: DWORD;                       // TASKDIALOG_FLAGS (TDF_XXX) flags
    dwCommonButtons: DWORD;               // TASKDIALOG_COMMON_BUTTON (TDCBF_XXX) flags
    pszWindowTitle: LPCWSTR;              // string or MAKEINTRESOURCE()
    case Integer of
      0: (hMainIcon: HICON);
      1: (pszMainIcon: LPCWSTR;
          pszMainInstruction: LPCWSTR;
          pszContent: LPCWSTR;
          cButtons: UINT;
          pButtons: PTaskDialogButton;
          nDefaultButton: Integer;
          cRadioButtons: UINT;
          pRadioButtons: PTaskDialogButton;
          nDefaultRadioButton: Integer;
          pszVerificationText: LPCWSTR;
          pszExpandedInformation: LPCWSTR;
          pszExpandedControlText: LPCWSTR;
          pszCollapsedControlText: LPCWSTR;
          case Integer of
            0: (hFooterIcon: HICON);
            1: (pszFooterIcon: LPCWSTR;
                pszFooter: LPCWSTR;
                pfCallback: TFTaskDialogCallback;
                lpCallbackData: LONGINT;
                cxWidth: UINT  // width of the Task Dialog's client area in DLU's.
                               // If 0, Task Dialog will calculate the ideal width.
              );
          );
  end;
  {$EXTERNALSYM _TASKDIALOGCONFIG}
  _TASKDIALOGCONFIG = TASKDIALOGCONFIG;
  PTaskDialogConfig = ^TTaskDialogConfig;
  TTaskDialogConfig = TASKDIALOGCONFIG;

{$EXTERNALSYM TaskDialogIndirect}
function TaskDialogIndirect(const pTaskConfig: TTaskDialogConfig;
  pnButton: PInteger; pnRadioButton: PInteger; pfVerificationFlagChecked: PBOOL): HRESULT;

{$EXTERNALSYM TaskDialog}
function TaskDialog(hwndParent: HWND; hInstance: HINST; pszWindowTitle,
  pszMainInstruction, pszContent: LPCWSTR; dwCommonButtons: DWORD;
  pszIcon: LPCWSTR; pnButton: PInteger): HRESULT;



type

{ Translated from WINDEF.H }

  WCHAR = WideChar;
  PWChar = PWideChar;

  LPSTR = PAnsiChar;
  PLPSTR = ^LPSTR;
  LPCSTR = PAnsiChar;
  LPCTSTR = {$IFDEF UNICODE}PWideChar{$ELSE}PAnsiChar{$ENDIF};
  LPTSTR = {$IFDEF UNICODE}PWideChar{$ELSE}PAnsiChar{$ENDIF};
  PLPCTSTR = {$IFDEF UNICODE}PPWideChar{$ELSE}PPAnsiChar{$ENDIF};
  PLPTSTR = {$IFDEF UNICODE}PPWideChar{$ELSE}PPAnsiChar{$ENDIF};
  LPWSTR = PWideChar;
  PLPWSTR = ^LPWSTR;
  LPCWSTR = PWideChar;


  TCustomTaskDialog = class;

  TTaskDialogFlag = (tfEnableHyperlinks, tfUseHiconMain,
    tfUseHiconFooter, tfAllowDialogCancellation,
    tfUseCommandLinks, tfUseCommandLinksNoIcon,
    tfExpandFooterArea, tfExpandedByDefault,
    tfVerificationFlagChecked, tfShowProgressBar,
    tfShowMarqueeProgressBar, tfCallbackTimer,
    tfPositionRelativeToWindow, tfRtlLayout,
    tfNoDefaultRadioButton, tfCanBeMinimized);
  TTaskDialogFlags = set of TTaskDialogFlag;

  TTaskDialogCommonButton = (tcbOk, tcbYes, tcbNo, tcbCancel, tcbRetry, tcbClose);
  TTaskDialogCommonButtons = set of TTaskDialogCommonButton;

  TTaskDialogIcon = Low(Integer)..High(Integer);

  { TProgressBar }

  TProgressRange = Integer; // for backward compatibility

  TProgressBarOrientation = (pbHorizontal, pbVertical);

  TProgressBarStyle = (pbstNormal, pbstMarquee);

  TProgressBarState = (pbsNormal, pbsError, pbsPaused);



  TTaskDialogProgressBar = class(TPersistent)
  private
    FClient: TCustomTaskDialog;
    FMarqueeSpeed: Cardinal;
    FMax: Integer;
    FMin: Integer;
    FPosition: Integer;
    FState: TProgressBarState;
    procedure SetMarqueeSpeed(const Value: Cardinal);
    procedure SetMax(const Value: Integer);
    procedure SetMin(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetState(const Value: TProgressBarState);
  public
    constructor Create(AClient: TCustomTaskDialog);
    procedure Initialize;
  published
    property MarqueeSpeed: Cardinal read FMarqueeSpeed write SetMarqueeSpeed default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Min: Integer read FMin write SetMin default 0;
    property Position: Integer read FPosition write SetPosition default 0;
    property State: TProgressBarState read FState write SetState default pbsNormal;
  end;

  TModalResult = Low(Integer)..High(Integer);

  TTaskDialogBaseButtonItem = class(TCollectionItem)
  private
    FElevated: Boolean;
    FCaption: string;
    FClient: TCustomTaskDialog;
    FEnabled: Boolean;
    FModalResult: TModalResult;
    FTextWStr: LPCWSTR;
    function GetDefault: Boolean;
    function GetTextWStr: LPCWSTR;
    procedure SetCaption(const Value: string);
    procedure SetDefault(const Value: Boolean);
    procedure SetEnabled(const Value: Boolean);
  protected
    procedure DoButtonClick; virtual;
    procedure DoSetEnabled; virtual;
    function GetButtonText: string; virtual;
    property Client: TCustomTaskDialog read FClient;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Click;
    procedure SetInitialState; virtual;
    property ModalResult: TModalResult read FModalResult write FModalResult;
    property TextWStr: LPCWSTR read GetTextWStr;
  published
    property Caption: string read FCaption write SetCaption;
    property Default: Boolean read GetDefault write SetDefault default False;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Elevated: Boolean read FElevated write FElevated default False;
  end;

  TTaskDialogButtonItem = class(TTaskDialogBaseButtonItem)
  private
    FCommandLinkHint: string;
    FElevationRequired: Boolean;
    procedure DoSetElevationRequired;
    procedure SetElevationRequired(const Value: Boolean);
  protected
    function GetButtonText: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure SetInitialState; override;
  published
    property CommandLinkHint: string read FCommandLinkHint write FCommandLinkHint;
    property ElevationRequired: Boolean read FElevationRequired write SetElevationRequired default False;
    property ModalResult;
  end;

  TTaskDialogRadioButtonItem = class(TTaskDialogBaseButtonItem)
  protected
    procedure DoButtonClick; override;
    procedure DoSetEnabled; override;
  public
    constructor Create(Collection: TCollection); override;
  end;

  TTaskDialogButtonList = array of TTaskDialogButton;

  TTaskDialogButtons = class;

  TTaskDialogButtonsEnumerator = class
  private
    FIndex: Integer;
    FCollection: TTaskDialogButtons;
  public
    constructor Create(ACollection: TTaskDialogButtons);
    function GetCurrent: TTaskDialogBaseButtonItem;
    function MoveNext: Boolean;
    property Current: TTaskDialogBaseButtonItem read GetCurrent;
  end;

  TTaskDialogButtons = class(TOwnedCollection)
  private
    FButtonList:  TTaskDialogButtonList;
    FButtonListPtr: PTaskDialogButton;
    FDefaultButton: TTaskDialogBaseButtonItem;
    function GetItem(Index: Integer): TTaskDialogBaseButtonItem;
    procedure SetDefaultButton(const Value: TTaskDialogBaseButtonItem);
    procedure SetItem(Index: Integer; const Value: TTaskDialogBaseButtonItem);
  public
    destructor Destroy; override;
    function Add: TTaskDialogBaseButtonItem;
    function Buttons: PTaskDialogButton;
    function FindButton(AModalResult: TModalResult): TTaskDialogBaseButtonItem;
    function GetEnumerator: TTaskDialogButtonsEnumerator;
    procedure SetInitialState; dynamic;
    property DefaultButton: TTaskDialogBaseButtonItem read FDefaultButton write SetDefaultButton;
    property Items[Index: Integer]: TTaskDialogBaseButtonItem read GetItem write SetItem; default;
  end;

  TTaskDlgClickEvent = procedure(Sender: TObject; ModalResult: TModalResult; var CanClose: Boolean) of object;
  TTaskDlgTimerEvent = procedure(Sender: TObject; TickCount: Cardinal; var Reset: Boolean) of object;

  TCustomTaskDialog = class(TComponent)
  private
    FButton: TTaskDialogButtonItem;
    FButtons: TTaskDialogButtons;
    FCaption: string;
    FCommonButtons: TTaskDialogCommonButtons;
    FCustomFooterIcon: TIcon;
    FCustomMainIcon: TIcon;
    FDefaultButton: TTaskDialogCommonButton;
    FExpandButtonCaption: string;
    FExpanded: Boolean;
    FExpandedText: string;
    FFlags: TTaskDialogFlags;
    FFooterIcon: TTaskDialogIcon;
    FFooterText: string;
    FHandle: HWND;
    FHelpContext: Integer;
    FMainIcon: TTaskDialogIcon;
    FModalResult: TModalResult;
    FProgressBar: TTaskDialogProgressBar;
    FRadioButton: TTaskDialogRadioButtonItem;
    FRadioButtons: TTaskDialogButtons;
    FText: string;
    FTitle: string;
    FURL: string;
    FVerificationText: string;
    FOnButtonClicked: TTaskDlgClickEvent;
    FOnDialogConstructed: TNotifyEvent;
    FOnDialogCreated: TNotifyEvent;
    FOnDialogDestroyed: TNotifyEvent;
    FOnExpanded: TNotifyEvent;
    FOnHyperlinkClicked: TNotifyEvent;
    FOnNavigated: TNotifyEvent;
    FOnRadioButtonClicked: TNotifyEvent;
    FOnTimer: TTaskDlgTimerEvent;
    FOnVerificationClicked: TNotifyEvent;
    procedure SetButtons(const Value: TTaskDialogButtons);
    procedure SetExpandedText(const Value: string);
    procedure SetFooterIcon(const Value: TTaskDialogIcon);
    procedure SetFooterText(const Value: string);
    procedure SetFlags(const Value: TTaskDialogFlags);
    procedure SetMainIcon(const Value: TTaskDialogIcon);
    procedure SetRadioButtons(const Value: TTaskDialogButtons);
    procedure SetText(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetCustomFooterIcon(const Value: TIcon);
    procedure SetCustomMainIcon(const Value: TIcon);
  protected
    function DoExecute(ParentWnd: HWND): Boolean; dynamic;
    procedure DoOnButtonClicked(AModalResult: Integer; var CanClose: Boolean); dynamic;
    procedure DoOnDialogContructed; dynamic;
    procedure DoOnDialogCreated; dynamic;
    procedure DoOnDialogDestroyed; dynamic;
    procedure DoOnExpandButtonClicked(Expanded: Boolean); dynamic;
    procedure DoOnHelp; dynamic;
    procedure DoOnHyperlinkClicked(const AURL: string); dynamic;
    procedure DoOnNavigated; dynamic;
    procedure DoOnRadioButtonClicked(ButtonID: Integer); dynamic;
    procedure DoOnTimer(TickCount: Cardinal; var Reset: Boolean); dynamic;
    procedure DoOnVerificationClicked(Checked: Boolean); dynamic;
    procedure ShowHelpException(E: Exception); dynamic;
  protected
    function CallbackProc(hwnd: HWND; msg: UINT; wParam: WPARAM;
      lParam: LPARAM; lpRefData: LONGINT): HResult; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; overload; dynamic;
    function Execute(ParentWnd: HWND): Boolean; overload; dynamic;
    property Button: TTaskDialogButtonItem read FButton write FButton;
    property Buttons: TTaskDialogButtons read FButtons write SetButtons;
    property Caption: string read FCaption write FCaption;
    property CommonButtons: TTaskDialogCommonButtons read FCommonButtons write FCommonButtons default [tcbOk, tcbCancel];
    property CustomFooterIcon: TIcon read FCustomFooterIcon write SetCustomFooterIcon;
    property CustomMainIcon: TIcon read FCustomMainIcon write SetCustomMainIcon;
    property DefaultButton: TTaskDialogCommonButton read FDefaultButton write FDefaultButton default tcbOk;
    property ExpandButtonCaption: string read FExpandButtonCaption write FExpandButtonCaption;
    property Expanded: Boolean read FExpanded;
    property ExpandedText: string read FExpandedText write SetExpandedText;
    property Flags: TTaskDialogFlags read FFlags write SetFlags default [tfAllowDialogCancellation];
    property FooterIcon: TTaskDialogIcon read FFooterIcon write SetFooterIcon default tdiNone;
    property FooterText: string read FFooterText write SetFooterText;
    property Handle: HWND read FHandle;
    property HelpContext: Integer read FHelpContext write FHelpContext default 0;
    property MainIcon: TTaskDialogIcon read FMainIcon write SetMainIcon default tdiInformation;
    property ModalResult: TModalResult read FModalResult write FModalResult;
    property ProgressBar: TTaskDialogProgressBar read FProgressBar write FProgressBar;
    property RadioButton: TTaskDialogRadioButtonItem read FRadioButton;
    property RadioButtons: TTaskDialogButtons read FRadioButtons write SetRadioButtons;
    property Text: string read FText write SetText;
    property Title: string read FTitle write SetTitle;
    property URL: string read FURL;
    property VerificationText: string read FVerificationText write FVerificationText;
    property OnButtonClicked: TTaskDlgClickEvent read FOnButtonClicked write FOnButtonClicked;
    property OnDialogConstructed: TNotifyEvent read FOnDialogConstructed write FOnDialogConstructed;
    property OnDialogCreated: TNotifyEvent read FOnDialogCreated write FOnDialogCreated;
    property OnDialogDestroyed: TNotifyEvent read FOnDialogDestroyed write FOnDialogDestroyed;
    property OnExpanded: TNotifyEvent read FOnExpanded write FOnExpanded;
    property OnHyperlinkClicked: TNotifyEvent read FOnHyperlinkClicked write FOnHyperlinkClicked;
    property OnNavigated: TNotifyEvent read FOnNavigated write FOnNavigated;
    property OnRadioButtonClicked: TNotifyEvent read FOnRadioButtonClicked write FOnRadioButtonClicked;
    property OnTimer: TTaskDlgTimerEvent read FOnTimer write FOnTimer;
    property OnVerificationClicked: TNotifyEvent read FOnVerificationClicked write FOnVerificationClicked;
  end;

  TTaskDialog = class(TCustomTaskDialog)
  published
    property Buttons;
    property Caption;
    property CommonButtons;
    property CustomFooterIcon;
    property CustomMainIcon;
    property DefaultButton;
    property ExpandButtonCaption;
    property ExpandedText;
    property Flags;
    property FooterIcon;
    property FooterText;
    property HelpContext;
    property MainIcon;
    property ProgressBar;
    property RadioButtons;
    property Text;
    property Title;
    property VerificationText;
    property OnButtonClicked;
    property OnDialogConstructed;
    property OnDialogCreated;
    property OnDialogDestroyed;
    property OnExpanded;
    property OnHyperlinkClicked;
    property OnNavigated;
    property OnRadioButtonClicked;
    property OnTimer;
    property OnVerificationClicked;
  end;

implementation
const
{$IFDEF MSWINDOWS}
  cctrl = comctl32; { From Windows.pas }
{$ENDIF}
{$IFDEF LINUX}
  cctrl = 'libcomctl32.borland.so';
{$ENDIF}
{ Task window management }

type
{$IF DEFINED(CLR)}
  TTaskWindow = class
    Next: TTaskWindow;
    Window: HWnd;
  end;
  TTaskWindowType = TTaskWindow;
{$ELSE}
  PTaskWindow = ^TTaskWindow;
  TTaskWindow = record
    Next: PTaskWindow;
    Window: HWnd;
  end;
  TTaskWindowType = PTaskWindow;
{$IFEND}

var
  ComCtl32DLL: THandle;
  _InitCommonControlsEx: function(var ICC: TInitCommonControlsEx): Bool stdcall;
var
  TaskActiveWindow: HWnd = 0;
  TaskFirstWindow: HWnd = 0;
  TaskFirstTopMost: HWnd = 0;
  DisablingWindows: Boolean = False;
  TaskWindowList: TTaskWindowType = nil;
var
  FocusMessages: Boolean = True;
  FocusCount: Integer = 0;

procedure InitCommonControls; external cctrl name 'InitCommonControls';

function WStrCopy(Dest: PWideChar; const Source: PWideChar): PWideChar;
var
  Src : PWideChar;
begin
  Result := Dest;
  Src := Source;
  while (Src^ <> #$00) do
  begin
    Dest^ := Src^;
    Inc(Src);
    Inc(Dest);
  end;
  Dest^ := #$00;
end;

function WStrLCopy(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar;
var
  Src : PWideChar;
begin
  Result := Dest;
  Src := Source;
  while (Src^ <> #$00) and (MaxLen > 0) do
  begin
    Dest^ := Src^;
    Inc(Src);
    Inc(Dest);
    Dec(MaxLen);
  end;
  Dest^ := #$00;
end;

function WStrPCopy(Dest: PWideChar; const Source: WideString): PWideChar;
begin
  Result := WStrLCopy(Dest, PWideChar(Source), Length(Source));
end;

function WStrPLCopy(Dest: PWideChar; const Source: WideString; MaxLen: Cardinal): PWideChar;
begin
  Result := WStrLCopy(Dest, PWideChar(Source), MaxLen);
end;function AllocCoTaskMemStr(const S: string): LPCWSTR;

var
  Len: Integer;

begin

  Len := Length(S);
  Result := CoTaskMemAlloc((Len * SizeOf(WideChar)) + SizeOf(WideChar));
  Result := WStrPLCopy(Result, WideString(S), Len);

end;



function DoDisableWindow(Window: HWnd; Data: LPARAM): Bool; {$IFNDEF CLR}stdcall;{$ENDIF}
var
  P: TTaskWindowType;
begin
  if (Window <> TaskActiveWindow) and IsWindowVisible(Window) and
    IsWindowEnabled(Window) then
  begin
{$IF DEFINED(CLR)}
    P := TTaskWindow.Create;
{$ELSE}
    New(P);
{$IFEND}
    P.Next := TaskWindowList;
    P.Window := Window;
    TaskWindowList := P;
    EnableWindow(Window, False);
  end;
  Result := True;
end;
function SaveFocusState: TFocusState;
begin
  Result := TFocusState(FocusCount);
end;

procedure RestoreFocusState(FocusState: TFocusState);
begin
  FocusCount := Integer(FocusState);
end;

procedure EnableTaskWindows(WindowList: TTaskWindowList);
var
  P: TTaskWindowType;
begin
{$IF DEFINED(CLR)}
  P := TTaskWindow(WindowList);
  while P <> nil do
  begin
    if IsWindow(P.Window) then EnableWindow(P.Window, True);
    P := P.Next;
  end;
{$ELSE}
  while WindowList <> nil do
  begin
    P := WindowList;
    if IsWindow(P^.Window) then EnableWindow(P^.Window, True);
    WindowList := P^.Next;
    Dispose(P);
  end;
{$IFEND}
end;


function DisableTaskWindows(ActiveWindow: HWnd): TTaskWindowList;
var
  SaveActiveWindow: HWND;
  SaveWindowList: TTaskWindowType;
  EnumProc: TFNWndEnumProc; // keep a reference to the delegate!

  procedure ProcessWMEnableMessages;
  var
    Msg: TMsg;
  begin
    while PeekMessage(Msg, 0, WM_ENABLE, WM_ENABLE, PM_REMOVE) do
      DispatchMessage(Msg);
  end;

begin
  { The following is to work-around an issue with WindowsXP that causes
    disabled windows to be re-enabled if the application doesn't process
    messages for a certain timeout period.  Windows posts a WM_ENABLE message
    that tells the window to re-enable, so unless we process that message,
    we don't know that it is about to be re-enabled so DoDisableWindow will
    ignore the window since it thinks it is still disabled.  So when the app
    begins to process messages again, the WM_ENABLE is allowed through and the
    window is then re-enabled causing dialogs to show behind other windows. }
                                                                                       
//  ProcessWMEnableMessages;
  Result := nil;
  SaveActiveWindow := TaskActiveWindow;
  SaveWindowList := TaskWindowList;
  TaskActiveWindow := ActiveWindow;
  TaskWindowList := nil;
  EnumProc := @DoDisableWindow;
  try
    DisablingWindows := True;
    try
      EnumThreadWindows(GetCurrentThreadID, EnumProc, 0);
      Result := TaskWindowList;
    except
      EnableTaskWindows(TaskWindowList);
      raise;
    end;
  finally
    DisablingWindows := False;
    TaskWindowList := SaveWindowList;
    TaskActiveWindow := SaveActiveWindow;
  end;
end;

function SendTextMessage(Handle: HWND; Msg: UINT; WParam: WPARAM; LParam: wideString): LRESULT;
begin
  Result := SendMessage(Handle, Msg, WParam, Windows.LPARAM(PWideChar(LParam)));
end;

procedure InitComCtl;
begin
  if ComCtl32DLL = 0 then
  begin
    ComCtl32DLL := GetModuleHandle(cctrl);
    if ComCtl32DLL <> 0 then
      @_InitCommonControlsEx := GetProcAddress(ComCtl32DLL, 'InitCommonControlsEx');
  end;
end;

function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool;
begin
  if ComCtl32DLL = 0 then InitComCtl;
  Result := Assigned(_InitCommonControlsEx) and _InitCommonControlsEx(ICC);
end;


var
  _TaskDialogIndirect: function(const pTaskConfig: TTaskDialogConfig;
    pnButton: PInteger; pnRadioButton: PInteger;
    pfVerificationFlagChecked: PBOOL): HRESULT; stdcall;

  _TaskDialog: function(hwndParent: HWND; hInstance: HINST;
    pszWindowTitle: LPCWSTR; pszMainInstruction: LPCWSTR; pszContent: LPCWSTR;
    dwCommonButtons: DWORD; pszIcon: LPCWSTR; pnButton: PInteger): HRESULT; stdcall;

function TaskDialogIndirect(const pTaskConfig: TTaskDialogConfig;
  pnButton: PInteger; pnRadioButton: PInteger; pfVerificationFlagChecked: PBOOL): HRESULT;
begin
  if Assigned(_TaskDialogIndirect) then
    Result := _TaskDialogIndirect(pTaskConfig, pnButton, pnRadioButton,
      pfVerificationFlagChecked)
  else
  begin
    InitComCtl;
    Result := E_NOTIMPL;
    if ComCtl32DLL <> 0 then
    begin
      @_TaskDialogIndirect := GetProcAddress(ComCtl32DLL, 'TaskDialogIndirect');
      if Assigned(_TaskDialogIndirect) then
        Result := _TaskDialogIndirect(pTaskConfig, pnButton, pnRadioButton,
          pfVerificationFlagChecked)
    end;
  end;
end;

function TaskDialog(hwndParent: HWND; hInstance: HINST; pszWindowTitle,
  pszMainInstruction, pszContent: LPCWSTR; dwCommonButtons: DWORD;
  pszIcon: LPCWSTR; pnButton: PInteger): HRESULT;
begin
  if Assigned(_TaskDialog) then
    Result := _TaskDialog(hwndParent, hInstance, pszWindowTitle, pszMainInstruction,
      pszContent, dwCommonButtons, pszIcon, pnButton)
  else
  begin
    InitComCtl;
    Result := E_NOTIMPL;
    if ComCtl32DLL <> 0 then
    begin
      @_TaskDialog := GetProcAddress(ComCtl32DLL, 'TaskDialog');
      if Assigned(_TaskDialog) then
        Result := _TaskDialog(hwndParent, hInstance, pszWindowTitle, pszMainInstruction,
          pszContent, dwCommonButtons, pszIcon, pnButton);
    end;
  end;
end;


{ TTaskDialogProgressBar }

constructor TTaskDialogProgressBar.Create(AClient: TCustomTaskDialog);
begin
  inherited Create;
  FClient := AClient;
  FMax := 100;
  FMin := 0;
  FPosition := 0;
  FMarqueeSpeed := 0;
  FState := pbsNormal;
end;

procedure TTaskDialogProgressBar.SetMax(const Value: Integer);
begin
  if Value <> FMax then
  begin
    if Value < FMin then
      raise EInvalidOperation.CreateFmt(SPropertyOutOfRange, [Classname]);
    FMax := Value;
    if (FClient.Handle <> 0) and not (tfShowMarqueeProgressBar in FClient.Flags) then
      SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_RANGE, 0, MakeLParam(FMin, FMax));
  end;
end;

procedure TTaskDialogProgressBar.SetMin(const Value: Integer);
begin
  if Value <> FMin then
  begin
    if Value > FMax then
      raise EInvalidOperation.CreateFmt(SPropertyOutOfRange, [Classname]);
    FMin := Value;
    if (FClient.Handle <> 0) and not (tfShowMarqueeProgressBar in FClient.Flags) then
      SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_RANGE, 0, MakeLParam(FMin, FMax));
  end;
end;

procedure TTaskDialogProgressBar.SetPosition(const Value: Integer);
begin
  if Value <> FPosition then
  begin
    if (Value < 0) or (Value > High(Word)) then
      raise Exception.CreateFmt(SOutOfRange, [0, High(Word)]);
    FPosition := Value;
    if (FClient.Handle <> 0) and not (tfShowMarqueeProgressBar in FClient.Flags) then
      SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_POS, FPosition, 0);
  end;
end;

const
  ProgressBarStates: array[TProgressBarState] of Integer = (PBST_NORMAL, PBST_ERROR, PBST_PAUSED);

procedure TTaskDialogProgressBar.SetState(const Value: TProgressBarState);
begin
  if Value <> FState then
  begin
    FState := Value;
    if (FClient.Handle <> 0) then
      SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_STATE, ProgressBarStates[FState], 0);
  end;
end;

procedure TTaskDialogProgressBar.SetMarqueeSpeed(const Value: Cardinal);
begin
  if Value <> FMarqueeSpeed then
  begin
    FMarqueeSpeed := Value;
    if (FClient.Handle <> 0) and (tfShowMarqueeProgressBar in FClient.Flags) then
      SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_MARQUEE, Windows.WPARAM(BOOL(True)), FMarqueeSpeed);
  end;
end;

procedure TTaskDialogProgressBar.Initialize;
begin
  SendMessage(FClient.Handle, TDM_SET_MARQUEE_PROGRESS_BAR,
    Windows.WPARAM(BOOL((tfShowMarqueeProgressBar in FClient.Flags))), 0);
  if (tfShowMarqueeProgressBar in FClient.Flags) then
    SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_MARQUEE, Windows.WPARAM(BOOL(True)), FMarqueeSpeed)
  else
  begin
    SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_RANGE, 0, MakeLParam(FMin, FMax));
    SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_POS, FPosition, 0);
  end;
  SendMessage(FClient.Handle, TDM_SET_PROGRESS_BAR_STATE, ProgressBarStates[FState], 0);
end;

{ TTaskDialogButton }

constructor TTaskDialogBaseButtonItem.Create(Collection: TCollection);
begin
  inherited;
  FCaption := '';
  FClient := TCustomtaskDialog(Collection.Owner);
  FEnabled := True;
  FElevated:=False;
  FModalResult := ID + 100; // Avoid mrNone..mrYesToAll and IDOK..IDCONTINUE
  FTextWStr := nil;
end;

destructor TTaskDialogBaseButtonItem.Destroy;
begin
  if FTextWStr <> nil then
    FreeAndNil(FTextWStr);
  inherited;
end;

procedure TTaskDialogBaseButtonItem.DoButtonClick;
begin
  if FClient.Handle <> 0 then
    SendMessage(FClient.Handle, TDM_CLICK_BUTTON, FModalResult, 0);
end;

procedure TTaskDialogBaseButtonItem.DoSetEnabled;
begin
  if FClient.Handle <> 0 then
    SendMessage(FClient.Handle, TDM_ENABLE_BUTTON, FModalResult, LPARAM(FEnabled))
end;

procedure TTaskDialogBaseButtonItem.Click;
begin
  DoButtonClick;
end;

function TTaskDialogBaseButtonItem.GetButtonText: string;
begin
  Result := FCaption;
end;

function TTaskDialogBaseButtonItem.GetDefault: Boolean;
begin
  Result := TTaskDialogButtons(Collection).DefaultButton = Self;
end;

function TTaskDialogBaseButtonItem.GetDisplayName: string;
begin
  Result := FCaption;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

function TTaskDialogBaseButtonItem.GetTextWStr: LPCWSTR;
var
  LText: string;
begin
  LText := GetButtonText;
  if FTextWStr <> nil then
    CoTaskMemFree(FTextWStr);
  FTextWStr := AllocCoTaskMemStr(LText);

  Result := FTextWStr;
end;

procedure TTaskDialogBaseButtonItem.SetCaption(const Value: string);
begin
  if Value <> FCaption then
  begin
    if Value = '' then
      raise Exception.Create('SInvalidTaskDlgButtonCaption');
    FCaption := Value;
  end;
end;

procedure TTaskDialogBaseButtonItem.SetDefault(const Value: Boolean);
begin
  if Value then
    TTaskDialogButtons(Collection).DefaultButton := Self
  else
    TTaskDialogButtons(Collection).DefaultButton := nil;
end;

procedure TTaskDialogBaseButtonItem.SetEnabled(const Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    DoSetEnabled;
  end;
end;

procedure TTaskDialogBaseButtonItem.SetInitialState;
begin
  if not FEnabled then
    DoSetEnabled;
    if Client.Handle <> 0 then
    SendMessage(Client.Handle, TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE,
      ModalResult, LPARAM(FElevated))
end;

{ TTaskDialogButtonItem }

constructor TTaskDialogButtonItem.Create(Collection: TCollection);
begin
  inherited;
  Caption := Format(STaskDlgButtonCaption, [ID + 1]);
  FElevationRequired := False;
end;

procedure TTaskDialogButtonItem.DoSetElevationRequired;
begin
  if Client.Handle <> 0 then
    SendMessage(Client.Handle, TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE,
      ModalResult, LPARAM(FElevationRequired))
end;

function TTaskDialogButtonItem.GetButtonText: string;
begin
  if (FCommandLinkHint <> '') and ((tfUseCommandLinks in Client.Flags) or
     (tfUseCommandLinksNoIcon in Client.Flags)) then
    Result := Caption + #10 + FCommandLinkHint
  else
    Result := inherited GetButtonText;
end;

procedure TTaskDialogButtonItem.SetElevationRequired(const Value: Boolean);
begin
  if Value <> FElevationRequired then
  begin
    FElevationRequired := Value;
    DoSetElevationRequired;
  end;
end;

procedure TTaskDialogButtonItem.SetInitialState;
begin
  inherited;
  if FElevationRequired then
    DoSetElevationRequired
end;

{ TTaskDialogRadioButtonItem }

constructor TTaskDialogRadioButtonItem.Create(Collection: TCollection);
begin
  inherited;
  Caption := Format(STaskDlgRadioButtonCaption, [ID + 1]);
end;

procedure TTaskDialogRadioButtonItem.DoButtonClick;
begin
  if Client.Handle <> 0 then
    SendMessage(Client.Handle, TDM_CLICK_RADIO_BUTTON, ModalResult, 0);
end;

procedure TTaskDialogRadioButtonItem.DoSetEnabled;
begin
  if Client.Handle <> 0 then
    SendMessage(Client.Handle, TDM_ENABLE_RADIO_BUTTON, ModalResult, LPARAM(Enabled))
end;

{ TTaskDialogButtonsEnumerator }

constructor TTaskDialogButtonsEnumerator.Create(ACollection: TTaskDialogButtons);
begin
  inherited Create;
  FIndex := -1;
  FCollection := ACollection;
end;

function TTaskDialogButtonsEnumerator.GetCurrent: TTaskDialogBaseButtonItem;
begin
  Result := FCollection[FIndex];
end;

function TTaskDialogButtonsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FCollection.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TTaskDialogButtons }

destructor TTaskDialogButtons.Destroy;
begin
{$IF DEFINED(CLR)}
  if FButtonListPtr <> nil then
    Marshal.FreeHGlobal(FButtonListPtr);
{$IFEND}
  inherited;
end;

function TTaskDialogButtons.Add: TTaskDialogBaseButtonItem;
begin
  Result := TTaskDialogBaseButtonItem(inherited Add);
end;

function TTaskDialogButtons.Buttons: PTaskDialogButton;
var
  I: Integer;
begin
  SetLength(FButtonList, Count);
  for I := 0 to Count - 1 do
  begin
    FButtonList[I].nButtonID := Items[I].ModalResult;
    FButtonList[I].pszButtonText := Items[I].TextWStr;
  end;
{$IF DEFINED(CLR)}
  if FButtonListPtr <> nil then
    Marshal.FreeHGlobal(FButtonListPtr);
  FButtonListPtr := ArrayToNativeBuf(FButtonList);
{$ELSE}
  FButtonListPtr := @FButtonList[0];
{$IFEND}
  Result := FButtonListPtr;
end;

function TTaskDialogButtons.FindButton(AModalResult: TModalResult): TTaskDialogBaseButtonItem;
var
  LButton: TTaskDialogBaseButtonItem;
begin       {
  Result := nil;
  for LButton in Self do
    if LButton.ModalResult = AModalResult then
    begin
      Result := LButton;
      Exit;
    end;   }
end;

function TTaskDialogButtons.GetEnumerator: TTaskDialogButtonsEnumerator;
begin
  Result := TTaskDialogButtonsEnumerator.Create(Self);
end;

function TTaskDialogButtons.GetItem(Index: Integer): TTaskDialogBaseButtonItem;
begin
  Result := TTaskDialogBaseButtonItem(inherited GetItem(Index));
end;

procedure TTaskDialogButtons.SetDefaultButton(const Value: TTaskDialogBaseButtonItem);
begin
  if Value <> FDefaultButton then
    FDefaultButton := Value;
end;

procedure TTaskDialogButtons.SetInitialState;
var
  I : Integer;
begin
  for I:= 0 to Self.Count - 1 do
    Self.Items[I].SetInitialState;
end;

procedure TTaskDialogButtons.SetItem(Index: Integer; const Value: TTaskDialogBaseButtonItem);
begin
  inherited SetItem(Index, Value);
end;

{ TCustomTaskDialog }

constructor TCustomTaskDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtons := TTaskDialogButtons.Create(Self, TTaskDialogButtonItem);
  FCommonButtons := [tcbOk, tcbCancel];
  FCustomFooterIcon := TIcon.Create;
  FCustomMainIcon := TIcon.Create;
  FDefaultButton := tcbOk;
  FFlags := [tfAllowDialogCancellation];
  FFooterIcon := tdiNone;
  FHandle := 0;
  FMainIcon := tdiInformation;
  FProgressBar := TTaskDialogProgressBar.Create(Self);
  FRadioButtons := TTaskDialogButtons.Create(Self, TTaskDialogRadioButtonItem);
end;

destructor TCustomTaskDialog.Destroy;
begin
  FButtons.Free;
  FCustomFooterIcon.Free;
  FCustomMainIcon.Free;
  FProgressBar.Free;
  FRadioButtons.Free;
  inherited;
end;

function TCustomTaskDialog.CallbackProc(hwnd: HWND; msg: UINT; wParam: WPARAM;
  lParam: LPARAM; lpRefData: LONGINT): HResult;
var
  LCanClose, LReset: Boolean;
begin
  Result := S_OK;
  case msg of
    TDN_BUTTON_CLICKED:
      begin
        LCanClose := True;
        DoOnButtonClicked(wParam, LCanClose);
        if not LCanClose then
          Result := S_FALSE;
      end;
    TDN_CREATED:
      DoOnDialogCreated;
    TDN_DESTROYED:
      DoOnDialogDestroyed;
    TDN_DIALOG_CONSTRUCTED:
      begin         
        FHandle := hwnd;
        FButtons.SetInitialState;
        FRadioButtons.SetInitialState;
        FProgressBar.Initialize;
        DoOnDialogContructed;
      end;
    TDN_EXPANDO_BUTTON_CLICKED:
      DoOnExpandButtonClicked(BOOL(wParam));
    TDN_HELP:
      DoOnHelp;
    TDN_HYPERLINK_CLICKED:
      DoOnHyperlinkClicked(LPCWSTR(lParam));
    TDN_NAVIGATED:
      DoOnNavigated;
    TDN_RADIO_BUTTON_CLICKED:
      DoOnRadioButtonClicked(wParam);
    TDN_TIMER:
      begin
        LReset := False;
        DoOnTimer(wParam, LReset);
        if LReset then
          Result := S_FALSE;
      end;
    TDN_VERIFICATION_CLICKED:
      DoOnVerificationClicked(wParam = 1);
  end;
end;

{$IF NOT DEFINED(CLR)}
function TaskDialogCallbackProc(hwnd: HWND; msg: UINT; wParam: WPARAM;
  lParam: LPARAM; lpRefData: LONGINT): HResult; stdcall;
begin
  Result := TCustomTaskDialog(Pointer(lpRefData)).CallbackProc(hwnd, msg,
    wparam, lparam, 0);
end;
{$IFEND}

type
{$IF DEFINED(CLR)}
  TTaskDlgIconMapType = Integer;
{$ELSE}
  TTaskDlgIconMapType = PWideChar;
{$IFEND}

const
  CTaskDlgIcons: array[tdiNone..tdiShield] of TTaskDlgIconMapType = (
{$IF DEFINED(CLR)}
    0,
{$ELSE}
    nil,
{$IFEND}
    TD_WARNING_ICON, TD_ERROR_ICON, TD_INFORMATION_ICON, TD_SHIELD_ICON);

function TCustomTaskDialog.DoExecute(ParentWnd: HWND): Boolean;
const
  CTaskDlgFlags: array[TTaskDialogFlag] of Cardinal = (
    TDF_Enable_Hyperlinks, TDF_Use_Hicon_Main,
    tdf_Use_Hicon_Footer, TDF_ALLOW_DIALOG_CANCELLATION,
    TDF_USE_COMMAND_LINKS, TDF_USE_COMMAND_LINKS_NO_ICON,
    TDF_EXPAND_FOOTER_AREA, TDF_EXPANDED_BY_DEFAULT,
    TDF_VERIFICATION_FLAG_CHECKED, TDF_SHOW_PROGRESS_BAR,
    TDF_SHOW_MARQUEE_PROGRESS_BAR, TDF_CALLBACK_TIMER,
    TDF_POSITION_RELATIVE_TO_WINDOW, TDF_RTL_LAYOUT,
    TDF_NO_DEFAULT_RADIO_BUTTON, TDF_CAN_BE_MINIMIZED);

  CTaskDlgCommonButtons: array[TTaskDialogCommonButton] of Cardinal = (
    TDCBF_OK_BUTTON, TDCBF_YES_BUTTON, TDCBF_NO_BUTTON,
    TDCBF_CANCEL_BUTTON, TDCBF_RETRY_BUTTON, TDCBF_CLOSE_BUTTON);

  CTaskDlgDefaultButtons: array[TTaskDialogCommonButton] of Integer = (
    IDOK, IDYES, IDNO, IDCANCEL, IDRETRY, IDCLOSE);

var
  LWindowList: TTaskWindowList;
  LModalResult: Integer;
  LRadioButton: Integer;
  LFlag: TTaskDialogFlag;
  LFocusState: TFocusState;
  LVerificationChecked: LongBool;
  LTaskDialog: TTaskDialogConfig;
  LCommonButton: TTaskDialogCommonButton;
begin
  if Win32MajorVersion < 6 then
    raise EPlatformVersionException.CreateFmt(SWindowsVistaRequired, [ClassName]);
  if not ThemeServices.ThemesEnabled then
    raise Exception.CreateFmt(SXPThemesRequired, [ClassName]);

{$IF NOT DEFINED(CLR)}
  FillChar(LTaskDialog, SizeOf(LTaskDialog), 0);
{$IFEND}
  with LTaskDialog do
  begin
    // Set Size, Parent window, Flags
    cbSize := SizeOf(LTaskDialog);
    hwndParent := ParentWnd;
    dwFlags := 0;
    for LFlag := Low(TTaskDialogFlag) to High(TTaskDialogFlag) do
      if LFlag in FFlags then
        dwFlags := dwFlags or CTaskDlgFlags[LFlag];

    // Set CommonButtons
    dwCommonButtons := 0;
    for LCommonButton := Low(TTaskDialogCommonButton) to High(TTaskDialogCommonButton) do
      if LCommonButton in FCommonButtons then
        dwCommonButtons := dwCommonButtons or CTaskDlgCommonButtons[LCommonButton];

    // Set Content, MainInstruction, Title, MainIcon, DefaultButton
    if FText <> '' then
      pszContent := {$IFNDEF CLR}PWideChar{$ENDIF}(WideString(FText));
    if FTitle <> '' then
      pszMainInstruction := {$IFNDEF CLR}PWideChar{$ENDIF}(WideString(FTitle));
    if FCaption <> '' then
      pszWindowTitle := {$IFNDEF CLR}PWideChar{$ENDIF}(WideString(FCaption));
    if tfUseHiconMain in FFlags then
      hMainIcon := FCustomMainIcon.Handle
    else
    begin
      if FMainIcon in [tdiNone..tdiShield] then
        pszMainIcon := LPCWSTR(CTaskDlgIcons[FMainIcon])
      else
        pszMainIcon := LPCWSTR(MakeIntResourceW(Word(FMainIcon)));
    end;
    nDefaultButton := CTaskDlgDefaultButtons[FDefaultButton];

    // Set Footer, FooterIcon
    if FFooterText <> '' then
      pszFooter := {$IFNDEF CLR}PWideChar{$ENDIF}(WideString(FFooterText));
    if tfUseHiconFooter in FFlags then
      hFooterIcon := FCustomFooterIcon.Handle
    else
    begin
      if FFooterIcon in [tdiNone..tdiShield] then
        pszFooterIcon := LPCWSTR(CTaskDlgIcons[FFooterIcon])
      else
        pszFooterIcon := LPCWSTR(MakeIntResourceW(Word(FFooterIcon)));
    end;

    // Set VerificationText, ExpandedInformation, CollapsedControlText
    if FVerificationText <> '' then
      pszVerificationText := {$IFNDEF CLR}PWideChar{$ENDIF}(WideString(FVerificationText));
    if FExpandedText <> '' then
      pszExpandedInformation := {$IFNDEF CLR}PWideChar{$ENDIF}(WideString(FExpandedText));
    if FExpandButtonCaption <> '' then
      pszCollapsedControlText := {$IFNDEF CLR}PWideChar{$ENDIF}(WideString(FExpandButtonCaption));

    // Set Buttons
    cButtons := FButtons.Count;
    if cButtons > 0 then
      pButtons := FButtons.Buttons;
    if FButtons.DefaultButton <> nil then
      nDefaultButton := FButtons.DefaultButton.ModalResult;

    // Set RadioButtons
    cRadioButtons := FRadioButtons.Count;
    if cRadioButtons > 0 then
      pRadioButtons := FRadioButtons.Buttons;
    if not (tfNoDefaultRadioButton in FFlags) and (FRadioButtons.DefaultButton <> nil) then
      nDefaultRadioButton := FRadioButtons.DefaultButton.ModalResult;

    // Prepare callback
{$IF DEFINED(CLR)}
    pfCallBack := @CallbackProc;
{$ELSE}
    lpCallbackData := LONGINT(Self);
    pfCallback := PFTASKDIALOGCALLBACK(@TaskDialogCallbackProc);
{$IFEND}
  end;

  LWindowList := DisableTaskWindows(ParentWnd);
  LFocusState := SaveFocusState;
  try
    Result := TaskDialogIndirect(LTaskDialog, {$IFNDEF CLR}@{$ENDIF}LModalResult,
      {$IFNDEF CLR}@{$ENDIF}LRadioButton, {$IFNDEF CLR}@{$ENDIF}LVerificationChecked) = S_OK;
    FModalResult := LModalResult;
    if Result then
    begin
      FButton := TTaskDialogButtonItem(FButtons.FindButton(FModalResult));
      FRadioButton := TTaskDialogRadioButtonItem(FRadioButtons.FindButton(LRadioButton));
      if LVerificationChecked then
        Include(FFlags, tfVerificationFlagChecked);
    end;
  finally
    EnableTaskWindows(LWindowList);
    SetActiveWindow(ParentWnd);
    RestoreFocusState(LFocusState);
  end;
end;

procedure TCustomTaskDialog.DoOnButtonClicked(AModalResult: Integer; var CanClose: Boolean);
begin
  if Assigned(FOnButtonClicked) then
  begin
    FButton := TTaskDialogButtonItem(FButtons.FindButton(AModalResult));
    FOnButtonClicked(Self, AModalResult, CanClose);
  end;
end;

procedure TCustomTaskDialog.DoOnDialogCreated;
begin
  if Assigned(FOnDialogCreated) then
    FOnDialogCreated(Self);
end;

procedure TCustomTaskDialog.DoOnDialogDestroyed;
begin
  if Assigned(FOnDialogDestroyed) then
    FOnDialogDestroyed(Self);
end;

procedure TCustomTaskDialog.DoOnDialogContructed;
begin
  if Assigned(FOnDialogConstructed) then
    FOnDialogConstructed(Self);
end;

procedure TCustomTaskDialog.DoOnExpandButtonClicked(Expanded: Boolean);
begin
  if Assigned(FOnExpanded) then
  begin
    FExpanded := Expanded;
    FOnExpanded(Self);
  end;
end;

procedure TCustomTaskDialog.DoOnHelp;
begin
  if FHelpContext <> 0 then
  try
    Application.HelpContext(FHelpContext);
  except
    on E: Exception do
      ShowHelpException(E);
  end;
end;

procedure TCustomTaskDialog.DoOnHyperlinkClicked(const AURL: string);
begin
  if Assigned(FOnHyperlinkClicked) then
  begin
    FURL := AURL;
    FOnHyperlinkClicked(Self);
  end;
end;

procedure TCustomTaskDialog.DoOnNavigated;
begin
  if Assigned(FOnNavigated) then
    FOnNavigated(Self);
end;

procedure TCustomTaskDialog.DoOnRadioButtonClicked(ButtonID: Integer);
begin
  if Assigned(FOnRadioButtonClicked) then
  begin
    FRadioButton := TTaskDialogRadioButtonItem(FRadioButtons.FindButton(ButtonID));
    FOnRadioButtonClicked(Self);
  end;
end;

procedure TCustomTaskDialog.DoOnTimer(TickCount: Cardinal; var Reset: Boolean);
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self, TickCount, Reset);
end;

procedure TCustomTaskDialog.DoOnVerificationClicked(Checked: Boolean);
begin
  if Assigned(FOnVerificationClicked) then
  begin
    if Checked then
      Include(FFlags, tfVerificationFlagChecked)
    else
      Exclude(FFlags, tfVerificationFlagChecked);
    FOnVerificationClicked(Self);
  end;
end;

function TCustomTaskDialog.Execute: Boolean;
var
  LParentWnd: HWND;
begin
  if Assigned(Screen.ActiveForm) then
    LParentWnd := Screen.ActiveForm.Handle
  else
  begin
    LParentWnd := Application.{ActiveForm}Handle;
    if LParentWnd = 0 then
      LParentWnd := Application.Handle;
  end;
  Result := Execute(LParentWnd);
end;

function TCustomTaskDialog.Execute(ParentWnd: HWND): Boolean;
begin
  FModalResult := 0;
  Result := DoExecute(ParentWnd);
end;

procedure TCustomTaskDialog.SetButtons(const Value: TTaskDialogButtons);
begin
  if Value <> FButtons then
    FButtons.Assign(Value);
end;

procedure TCustomTaskDialog.SetCustomFooterIcon(const Value: TIcon);
begin
  if Value <> FCustomFooterIcon then
    FCustomFooterIcon.Assign(Value);
end;

procedure TCustomTaskDialog.SetCustomMainIcon(const Value: TIcon);
begin
  if Value <> FCustomMainIcon then
    FCustomMainIcon.Assign(Value);
end;

procedure TCustomTaskDialog.SetExpandedText(const Value: string);
begin
  if Value <> FExpandedText then
  begin
    FExpandedText := Value;
    if FHandle <> 0 then
      SendTextMessage(FHandle, TDM_UPDATE_ELEMENT_TEXT, TDE_EXPANDED_INFORMATION, FExpandedText);
  end;
end;

procedure TCustomTaskDialog.SetFlags(const Value: TTaskDialogFlags);
begin
  if Value <> FFlags then
  begin
    if (tfVerificationFlagChecked in FFlags) <> (tfVerificationFlagChecked in Value) and
       (FHandle <> 0) then
      SendMessage(FHandle, TDM_CLICK_VERIFICATION,
        WPARAM((tfVerificationFlagChecked in Value)), LPARAM(False));
    FFlags := Value;
  end;
end;

procedure TCustomTaskDialog.SetFooterIcon(const Value: TTaskDialogIcon);
begin
  if Value <> FFooterIcon then
  begin
    FFooterIcon := Value;
    if FHandle <> 0 then
      SendMessage(FHandle, TDM_UPDATE_ICON, TDIE_ICON_FOOTER, LPARAM(CTaskDlgIcons[FFooterIcon]));
  end;
end;

procedure TCustomTaskDialog.SetFooterText(const Value: string);
begin
  if Value <> FFooterText then
  begin
    FFooterText := Value;
    if FHandle <> 0 then
      SendTextMessage(FHandle, TDM_UPDATE_ELEMENT_TEXT, TDE_FOOTER, FFooterText);
  end;
end;

procedure TCustomTaskDialog.SetMainIcon(const Value: TTaskDialogIcon);
begin
  if Value <> FMainIcon then
  begin
    FMainIcon := Value;
    if FHandle <> 0 then
      SendMessage(FHandle, TDM_UPDATE_ICON, TDIE_ICON_MAIN, LPARAM(CTaskDlgIcons[FMainIcon]));
  end;
end;

procedure TCustomTaskDialog.SetRadioButtons(const Value: TTaskDialogButtons);
begin
  if Value <> FRadioButtons then
    FRadioButtons.Assign(Value);
end;

procedure TCustomTaskDialog.SetText(const Value: string);
begin
  if Value <> FText then
  begin
    FText := Value;
    if FHandle <> 0 then
      SendTextMessage(FHandle, TDM_UPDATE_ELEMENT_TEXT, TDE_CONTENT, FText);
  end;
end;

procedure TCustomTaskDialog.SetTitle(const Value: string);
begin
  if Value <> FTitle then
  begin
    FTitle := Value;
    if FHandle <> 0 then
      SendTextMessage(FHandle, TDM_UPDATE_ELEMENT_TEXT, TDE_MAIN_INSTRUCTION, FTitle);
  end;
end;

procedure TCustomTaskDialog.ShowHelpException(E: Exception);
var
  Msg: string;
  Flags: Integer;
  SubE: Exception;
begin
  Flags := MB_OK or MB_ICONSTOP;
  if Application.UseRightToLeftReading then
    Flags := Flags or MB_RTLREADING;
  Msg := E.Message;
  while True do
  begin
    ///SubE := E. GetBaseException;
    if SubE <> E then
    begin
      E := SubE;
      if E.Message <> '' then
        Msg := E.Message;
    end
    else
      Break;
  end;
  if (Msg <> '') and (Msg[Length(Msg)] > '.') then
    Msg := Msg + '.';
{$IF DEFINED(CLR)}
  MessageBox(FHandle, Msg, Application.Title, Flags);
{$ELSE}
  MessageBox(FHandle, PChar(Msg), PChar(Application.Title), Flags);
{$IFEND}
end;


end.
