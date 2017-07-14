<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
<%@ page import ="java.sql.*" %>
<%@ page import ="javax.sql.*" %>
<%
try{
String user=request.getParameter("user"); 
session.putValue("user",user); 
String cid=request.getParameter("cid"); 
String auth=request.getParameter("auth"); 
String yr=request.getParameter("yr"); 
String emp=request.getParameter("emp"); 
String hsal=request.getParameter("hsal"); 
String brch=request.getParameter("brch"); 
String addr=request.getParameter("addr"); 
String t1=request.getParameter("t1"); 
String c1=request.getParameter("c1");
String y1=request.getParameter("y1");
String a1=request.getParameter("a1");
String t2=request.getParameter("t2");
String c2=request.getParameter("c2");
String y2=request.getParameter("y2");
String a2=request.getParameter("a2");
String jid=request.getParameter("jid");
String ja=request.getParameter("ja");
String jt=request.getParameter("jt");
String js=request.getParameter("js");
String jid2=request.getParameter("jid2");
String ja2=request.getParameter("ja2");
String jt2=request.getParameter("jt2");
String js2=request.getParameter("js2");
Class.forName("com.mysql.jdbc.Driver"); 
java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/project",
"root","toor"); 
Statement st= con.createStatement(); 
ResultSet rs; 
int i=st.executeUpdate("insert into company values ('"+user+"','"+cid+"','"+auth+"','"+yr+"','"+emp+"','"+hsal+"','"+brch+"','"+addr+"','"+t1+"','"+c1+"','"+y1+"','"+a1+"','"+t2+"','"+c2+"','"+y2+"','"+a2+"','"+jid+"','"+ja+"','"+jt+"','"+js+"','"+jid2+"','"+ja2+"','"+jt2+"','"+js2+"')"); 
}
catch(Exception e)
{ out.println(e.getMessage());
}
Class.forName("com.mysql.jdbc.Driver"); 
java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/project","root","toor"); 
String userrr=request.getParameter("user"); 
Statement st= con.createStatement(); 
ResultSet rs1=st.executeQuery("select * from company where user='"+userrr+"'"); 
if(rs1.next()){
%><script type="text/javascript" >
window.open("hr.html","_self");
</script>
<%} else {%><script type="text/javascript" >
alert("not registered");
window.open("hrreg.html","_self");
</script>
<% }
%>
</body>
</html>