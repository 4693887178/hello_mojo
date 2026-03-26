"""
RQAlpha Mojo - Excel Template
Ported from rqalpha/mod/rqalpha_mod_sys_analyser/report/excel_template.py
"""


struct ExcelTemplate:
    comptime SHEET_SUMMARY: String = "Summary"
    comptime SHEET_TRADES: String = "Trades"
    comptime SHEET_DAILY: String = "Daily"
    comptime SHEET_POSITIONS: String = "Positions"


def generate_csv_content(headers: List[String], rows: List[List[String]]) -> String:
    var content = ""
    
    for i in range(len(headers)):
        if i > 0:
            content += ","
        content += headers[i]
    content += "\n"
    
    for row in rows:
        for i in range(len(row)):
            if i > 0:
                content += ","
            content += row[i]
        content += "\n"
    
    return content


def generate_summary_csv(result: Dict[String, String]) raises -> String:
    var headers = List[String]()
    headers.append("Metric")
    headers.append("Value")
    
    var rows = List[List[String]]()
    for key in result.keys():
        var row = List[String]()
        row.append(key)
        row.append(result[key])
        rows.append(row^)
    
    return generate_csv_content(headers, rows)
