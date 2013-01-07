﻿<%@ LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<% Option Explicit %>
<% 'On Error Resume Next %>
<% Response.Charset="UTF-8" %>
<!-- #include file="../../c_option.asp" -->
<!-- #include file="../../../ZB_SYSTEM/function/c_function.asp" -->
<!-- #include file="../../../ZB_SYSTEM/function/c_system_lib.asp" -->
<!-- #include file="../../../ZB_SYSTEM/function/c_system_base.asp" -->
<!-- #include file="../../../ZB_SYSTEM/function/c_system_plugin.asp" -->
<!-- #include file="../../../ZB_SYSTEM/function/c_system_event.asp" -->
<!-- #include file="../../plugin/p_config.asp" -->
<!-- #include file="function.asp"-->
<%
Call System_Initialize()
'检查非法链接
Call CheckReference("")
'检查权限
If BlogUser.Level>1 Then Call ShowError(6)

If CheckPluginState("AppCentre")=False Then Call ShowError(48)

Call AppCentre_InitConfig

If Len(Request.QueryString("update"))=13 Then
	Response.Clear
	'Response.Write AppCentre_CheckSystemLast
	Response.End
End If

If Request.QueryString("last")="now" Then
	Response.Clear
	Response.Write AppCentre_CheckSystemLast
	Response.End
End If


If Request.QueryString("check")="now" Then
	Call AppCentre_CheckSystemIndex(BlogVersion)
End If

Dim PathAndCrc32
Set PathAndCrc32=New TMeta

Dim objXmlFile,strXmlFile,item
Dim fso, f, f1, fc, s
Set fso = CreateObject("Scripting.FileSystemObject")


If fso.FileExists(BlogPath & "zb_users/cache/"&BlogVersion&".xml") Then

	strXmlFile =BlogPath & "zb_users/cache/"&BlogVersion&".xml"

	Set objXmlFile=Server.CreateObject("Microsoft.XMLDOM")
	objXmlFile.async = False
	objXmlFile.ValidateOnParse=False
	objXmlFile.load(strXmlFile)
	If objXmlFile.readyState=4 Then
		If objXmlFile.parseError.errorCode <> 0 Then
		Else

			for each item in objXmlFile.documentElement.SelectNodes("file")
				PathAndCrc32.SetValue item.getAttributeNode("name").Value,item.getAttributeNode("crc32").Value
			next

		End If
	End If
End If


If CLng(Request.QueryString("crc32"))>0 Then

	Response.Clear
	If CLng(Request.QueryString("crc32"))<=Round(PathAndCrc32.Count/10) Then

		Dim i,j,k,l,m,n
		k=CLng(Request.QueryString("crc32"))
		i=(k-1)*10+1
		j=k*10
		m="<img src=\'"&BlogHost&"zb_system/image/admin/ok.png\'/>"
		n="<img src=\'"&BlogHost&"zb_system/image/admin/exclamation.png\' />"
		For l=i To j
			If l>PathAndCrc32.Count Then Exit For
			If CRC32(BlogPath & vbsunescape(PathAndCrc32.Names(l)))<>PathAndCrc32.Values(l) Then
				Response.Write "$('#td"&l&"').html('"&n&"').parent().addClass(""check_conflict"");_conflict+=1;_count.html(_conflict);"
			Else
				Response.Write "$('#td"&l&"').html('"&m&"').parent().addClass(""check_normal"");"
			End If
		Next
		
	End If
	Response.End

End If


BlogTitle="系统更新检查"
%>
<!--#include file="..\..\..\zb_system\admin\admin_header.asp"-->
<!--#include file="..\..\..\zb_system\admin\admin_top.asp"-->
        <div id="divMain">
          <div id="ShowBlogHint">
            <%Call GetBlogHint()%>
          </div>
          <div class="divHeader"><%=BlogTitle%></div>
          <div class="SubMenu">
            <% AppCentre_SubMenu(7)%>
          </div>
          <div id="divMain2">
            <form method="post" action="">
              <table border="1" width="100%" cellspacing="0" cellpadding="0" class="tableBorder tableBorder-thcenter">
                <tr>
                  <th width='50%'>当前版本</th>
                  <th>最新版本</th>
                </tr>
                <tr>
                  <td align='center' id='now'>Z-Blog <%=ZC_BLOG_VERSION%></td>
                  <td align='center' id='last'></td>
                </tr>
              </table>
              <p>
                <input type="submit" style="display:none;" value="升级新版程序" />
              </p>
              <div class="a"></div>
              <div class="divHeader">校验系统核心文件&nbsp;&nbsp;进度<span id="status">0</span>%；已发现<span id="count">0</span>个修改过的系统文件。<a href="update.asp?check=now"><img src="Images/refresh.png" width="16" alt="校验" /></a></div>
			  <div id="bar"></div>
              <table border="1" width="100%" cellspacing="0" cellpadding="0" class="tableBorder tableBorder-thcenter">
                <tr>
                  <th width='78%'>文件名</th>
                  <th id="_s">状态</th>
                </tr>
                <!--

 -->
                <%

Dim a,b,c,d,e
b=0
For Each a In PathAndCrc32.Names

If b>0 Then

c=vbsunescape(a)

Response.Write "<tr><td><img src='Images/document_empty.png' width='16' alt='' /> "& c &"</td><td id='td"&b&"' align='center'>"& e &"</td></tr>"
Response.Flush

End If
b=b+1
Next


%>
              </table>
              <p> </p>
            </form>
          </div>
        </div>
        <script type="text/javascript">ActiveLeftMenu("aAppcentre");</script> 
        <script type="text/javascript">
			var _max = parseInt("<%=Round(PathAndCrc32.Count/10)+1%>"),_conflict=0,_sort=0;
			var _bar = $("#bar"),_status = $("#status"),_count=$("#count");
			
			function crc32(i) {
			
				_bar.prev().hide();
				$.get("update.asp?crc32=" + i, 
				function(data) {
					if (data !== "") {
						i = i + 1;
						_bar.progressbar({
							value: (i / _max) * 100
						});
						_status.html(parseInt((i/_max)*100));
						eval(data);
						crc32(i);
			
					} else {
						_bar.hide();
						_bar.prev().show();
						$("#_s").html("<a href='javascript:void(0);'>修改排序</a>").find("a").click(function(){
							var o=$(this);
							switch(_sort){
								case 0:$(".check_normal").hide();_sort=1;break;
								case 1:$(".check_normal").show();$(".check_conflict").hide();_sort=2;break;
								case 2:$(".check_conflict").show();_sort=0;break;
							}
							return false
						});
					}
			
				});
			
			}
			
			function checklast(now, last) {
				var n = now.toString().match(/[0-9]{6}/);
				var l = last.toString().match(/[0-9]{6}/);
				if (l - n > 0) {
					$("form").attr("action", "update.asp?update=" + n + "-" + l);
					$("form input:submit").show();
			
			
				}
			
			}
			
			$(document).ready(function() {
			
				$.get("update.asp?last=now", 
				function(data) {
					$("#last").html("Z-Blog " + data);
					checklast($("#now").html(), $("#last").html());
			
				});
			
<%
If Request.QueryString("check")="now" Then
	Response.Write "crc32(1)"
End If
%>

   });
   
   </script>
        <%
	If login_pw<>"" Then
		Response.Write "<script type='text/javascript'>$('div.SubMenu a[href=\'login.asp\']').hide();$('div.footer_nav p').html('&nbsp;&nbsp;&nbsp;<b>"&login_un&"</b>您好,欢迎来到APP应用中心!').css('visibility','inherit');</script>"
	End If
%>
        <!--#include file="..\..\..\zb_system\admin\admin_footer.asp"-->