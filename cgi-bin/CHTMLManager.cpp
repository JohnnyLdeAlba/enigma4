#include <iostream>
#include <sstream>
#include <string>

using namespace std;

class CCoreManager {

	public:
		string *Output;
				
		template <typename T> string ToString(T Type);
		int ReplaceAll(string Search, string Replace);
		
		void Newline(void);
		void Display(void);
};

class CCSSManager : public CCoreManager {
	
	public:		
		void TopLeft(string Top = "none", string Left = "none");
		void BottomRight(string Bottom = "none", string Right = "none");
		void Size(string Width = "0px", string Height = "0px");
		
		void Layout(string Display = "block", string Position = "static");
		void Float(string Float = "none", string Clear = "none");
		
		void Margin(string Top = "0px", string Bottom = "0px",
					string Left = "0px", string Right = "0px");
		void Padding(string Top = "0px", string Bottom = "0px",
					string Left = "0px", string Right = "0px");
							
		void Border(string Top = "0px", string Bottom = "0px",
					string Left = "0px", string Right = "0px");
		void BorderStyle(string Top = "none", string Bottom = "none",
					string Left = "none", string Right = "none");
		void BorderColor(string Top = "transparent", string Bottom = "transparent",
					string Left = "transparent", string Right = "transparent");
							
		void BackgroundColor(string Color = "transparent");
		void BackgroundImage(string Url = "none", string Position = "top left",
									string Repeat = "repeat");
									
		void Font(string Family = "serif", string Weight = "normal",
			string Style = "normal", string Size = "medium", string Color = "#000000");
		void Text(string Align = "left", string Decoration = "none");
		
		void Begin(string Id);
		void End(void);
};

class CJScriptManager : public CCoreManager {

	public:
		void libAjax(void);
	
		void Add(string Statement);
		void Begin(string Operator, string Condition = "");
		void BeginFunction(string Operator, string Condition = "");
		void End(void);
};

class CHTMLManager : public CCoreManager {
	
	public:
		void BeginPanel(string Id);
		void EndPanel(void);
		
		void BeginField(string Id);
		void EndField(void);
};

template <typename T> string CCoreManager::ToString(T Type) {

	stringstream Stream;
	string String;

	Stream << Type;				
	String = Stream.str();
	
	return String;
}

int CCoreManager::ReplaceAll(string Search, string Replace) {

	size_t SearchPosition = 0;
	int Count = 0;
	
	while (true) {
	
		SearchPosition = Output->find(Search, SearchPosition);
		if (SearchPosition == string::npos)
			break;
			
		Output->replace(SearchPosition, Search.size(), Replace);
		Count++;
	}
	
	return Count;
}

void CCoreManager::Newline(void) {

	*Output+= "\n";
	return;
}

void CCoreManager::Display(void) {

	cout << *Output;
	return;
}

void CCSSManager::TopLeft(string Top, string Left) {

	if (Top not_eq "none") {
		*Output+= "top: "+Top+";";
		Newline();
	}
	
	if (Left not_eq "none") {
		*Output+= "left: "+Left+";";
		Newline();
	}
	
	return;
}

void CCSSManager::BottomRight(string Bottom, string Right) {

	if (Bottom not_eq "none") {
		*Output+= "top: "+Bottom+";";
		Newline();
	}
	
	if (Right not_eq "none") {
		*Output+= "left: "+Right+";";
		Newline();
	}
	
	return;
}

void CCSSManager::Size(string Width, string Height) {

	*Output+= "width: "+Width+";";
	Newline();
	*Output+= "height:"+Height+";";
	Newline();
	
	return;
}

void CCSSManager::Layout(string Display, string Position) {

	*Output+= "display: block;";
	Newline();
	*Output+= "position: static;";
	Newline();
	
	return;
}

void CCSSManager::Float(string Float, string Clear) {

	*Output+= "float: "+Float+";";
	Newline();
	*Output+= "clear: "+Clear+";";
	Newline();
	
	return;
}

void CCSSManager::Margin(string Top, string Bottom,
							string Left, string Right) {

	*Output+= "margin: "+Top+" "+Right+" "+Bottom+" "+Left+";";
	Newline();
	
	return;
}

void CCSSManager::Padding(string Top, string Bottom,
					string Left, string Right) {

	*Output+= "padding: "+Top+" "+Right+" "+Bottom+" "+Left+";";
	Newline();
	
	return;
}

void CCSSManager::Border(string Top, string Bottom,
					string Left, string Right) {

	*Output+= "border-width: "+Top+" "+Right+" "+Bottom+" "+Left+";";
	Newline();
	
	return;
}

void CCSSManager::BorderStyle(string Top, string Bottom,
					string Left, string Right) {

	*Output+= "border-style: "+Top+" "+Right+" "+Bottom+" "+Left+";";
	Newline();
	
	return;
}

void CCSSManager::BorderColor(string Top, string Bottom,
					string Left, string Right) {

	*Output+= "border-color: "+Top+" "+Right+" "+Bottom+" "+Left+";";
	Newline();
	
	return;
}

void CCSSManager::BackgroundColor(string Color) {

	*Output+= "background-color: "+Color+";";
	Newline();
	
	return;
}

void CCSSManager::BackgroundImage(string Url, string Position, string Repeat) {

	*Output+= "background-image: ";
	
	if (Url == "none")
		*Output+=  "none";
	else
		*Output+= "url("+Url+");";
	
	*Output+= ";";
	Newline();
	
	*Output+= "background-position: "+Position+";";
	Newline();
	*Output+= "background-repeat: "+Repeat+";";
	Newline();
	
	return;
}

void CCSSManager::Font(string Family, string Weight,
			string Style, string Size, string Color) {

	*Output+= "font-family: "+Family+";";
	Newline();
	*Output+= "font-weight: "+Weight+";";
	Newline();
	*Output+= "font-style: "+Style+";";
	Newline();
	*Output+= "font-size: #"+Size+";";
	Newline();
	*Output+= "color: "+Color+";";
	Newline();
	
	return;
}

void CCSSManager::Text(string Align, string Decoration) {

	*Output+= "text-align: "+Align+";";
	Newline();
	*Output+= "text-decoration: "+Decoration+";";
	Newline();
	
	return;
}

void CCSSManager::Begin(string Id) {
	
	*Output+= Id+" {";
	Newline();
	
	return;
}

void CCSSManager::End(void) {

	*Output+= "}";
	Newline();
	Newline();
	
	return;
}

void CJScriptManager::libAjax(void) {

	BeginFunction("get_ajax_interface");
		Begin("if", "window.XMLHttpRequest");
			Add("return new XMLHttpRequest()");
		End();
		
		Begin("if", "window.ActiveXObject");
			Add("return new ActiveXObject(\"Microsoft.XMLHTTP\")");
		End();
		
		Add("return null");
	End();
	
	Add("var ajax_interface = get_ajax_interface()");
	Newline();

	BeginFunction("get_element_interface", "id");
		Add("return document.getElementById(id)");
	End();
	
	BeginFunction("set_display", "id, display");
		Add("var element_interface = get_element_interface(id)");
		Add("element_interface.style.display = display");
		Add("return");
	End();
	
	BeginFunction("set_bgcolor", "id, color");
		Add("var element_interface = get_element_interface(id)");
		Add("element_interface.style.backgroundColor = color");
		Add("return");
	End();
	
	BeginFunction("request_get", "request, _handler_function");
		Begin("if", "ajax_interface == null");
			Add("return");
		End();
		
		Begin("if", "ajax_interface.readyState == 0 || ajax_interface.readyState == 4");
			Add("ajax_interface.open(\"GET\", request, true)");
			Add("ajax_interface.onreadystatechange = _handler_function");
			Add("ajax_interface.send(null)");
		End();
		
		Add("return");
	End();
	
	BeginFunction("get_responce");
		Add("return ajax_interface.responseText");
	End();
	
	BeginFunction("_handler_hyperlink");
		Begin("if", "ajax_interface.readyState == 4");
			Add("var viewport = new get_element_interface('viewport');");
			Add("viewport.innerHTML = get_responce();");
		End();
	End();
	
	return;
}

void CJScriptManager::Add(string Statement) {

	*Output+= Statement+";";
	Newline();
	
	return;
}

void CJScriptManager::Begin(string Operator, string Condition) {

	*Output+= Operator+" ("+Condition+")  {";
	Newline();
	
	return;
}

void CJScriptManager::BeginFunction(string Operator, string Condition) {

	Begin("function "+Operator, Condition);
	return;
}

void CJScriptManager::End(void) {

	*Output+= "}";
	Newline();
	Newline();
	
	return;
}

void CHTMLManager::BeginPanel(string Id) {

	*Output+= "<div id='"+Id+"'>";
	*Output+= "\n\n";
	
	return;
}

void CHTMLManager::EndPanel(void) {

	*Output+= "</div>";
	*Output+= "\n\n";
	
	return;
}

void CHTMLManager::BeginField(string Id) {

	*Output+= "<span id='"+Id+"'>";
	*Output+= "\n\n";
	
	return;
}

void CHTMLManager::EndField(void) {

	*Output+= "</span>";
	*Output+= "\n\n";
	
	return;
}

int main(int argc, char *argv[]) {

	string *Output = new string();
	CCSSManager *CSSManager = new CCSSManager();
	CJScriptManager *JScriptManager = new CJScriptManager();
	CHTMLManager *HTMLManager = new CHTMLManager();
	
	CSSManager->Output = Output;
	JScriptManager->Output = Output;
	HTMLManager->Output = Output;
	
	*Output+= "content-type: text/html\n\n";
	*Output+= "<style type='text/css'>\n";
	
	CSSManager->Begin("#panel1");
	CSSManager->Layout("block", "absolute");
	CSSManager->TopLeft("50%", "50%");
	CSSManager->Size("100px", "100px");
	CSSManager->Border("1px", "1px", "1px", "1px");
	CSSManager->BorderColor("#000000", "#000000", "#000000", "#000000");
	CSSManager->BorderStyle("solid", "solid", "solid", "solid");
	CSSManager->BackgroundColor("#880000");
	CSSManager->Text("center");
	CSSManager->End();
	
	*Output+= "</style>\n";
	
	HTMLManager->BeginPanel("panel1");
	*Output+= "...\n";
	HTMLManager->EndPanel();
	
	*Output+= "<script type='text/javascript'>\n";
	
	JScriptManager->libAjax();
	
	JScriptManager->BeginFunction("panel1_onmouseover");
	JScriptManager->Add("set_bgcolor('panel1', '#bb0000')");
	JScriptManager->End();
	
	JScriptManager->BeginFunction("panel1_onmouseout");
	JScriptManager->Add("set_bgcolor('panel1', '#990000')");
	JScriptManager->End();
	
	JScriptManager->Add("var element_interface = get_element_interface('panel1')");
	JScriptManager->Add("element_interface.onmouseover = panel1_onmouseover");
	JScriptManager->Add("element_interface.onmouseout = panel1_onmouseout");
	
	*Output+= "</script>\n";
	
	HTMLManager->Display();
	return 0;
}

/*
class CHTMLObject {

	public:
	// html-properties:
		string Tag, Name, Id, Class;
		string Type, Src, Alt, Href, Value;
		string Action, Method;
		string Align, VAlign;
		
		short CellPadding, CellSpacing;
		short Size, MaxLength, Rows, Cols;
		
		bool Checked, Selected;
		
	// css-properties:
		string Display, Position;
		string Float, Clear;
		
		string BorderStyle, BorderColor;
		string BackgroundColor, BackgroundImage;
		
		string FontFamily, FontColor;
		string FontWieght, FontStyle;
		string TextDecoration, TextAlign;
		
		short Width, Height;
		short Top, Bottom, Left, Right;
	
		short MarginTop, MarginBottom;
		short MarginLeft, MarginRight;

		short PaddingTop, PaddingBottom;
		short PaddingLeft, PaddingRight;

		short BorderTop, BorderBottom;
		short BorderLeft, BorderRight;
		
		short FontSize;
};

*/
