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
<%try{
String userr=request.getParameter("user"); 
session.putValue("user",userr); 
String age=request.getParameter("age"); 
String mnum=request.getParameter("mnum"); 
String fname=request.getParameter("fname"); 
String mname=request.getParameter("mname"); 
String addr=request.getParameter("addr"); 
String cid=request.getParameter("cid"); 
String uid=request.getParameter("uid");
String brch=request.getParameter("brch");
String sem=request.getParameter("sem");
String b10th=request.getParameter("10thb");
String p10th=request.getParameter("10thp");
String b12th=request.getParameter("12thb");
String p12th=request.getParameter("12thp");
String t1=request.getParameter("t1"); 
String c1=request.getParameter("c1");
String ds1=request.getParameter("ds1");
String de1=request.getParameter("de1");
String t2=request.getParameter("t2");
String c2=request.getParameter("c2");
String ds2=request.getParameter("ds2");
String de2=request.getParameter("de2");
String jid=request.getParameter("jid");
String ja=request.getParameter("ja");
String jt=request.getParameter("jt");
String js=request.getParameter("js");
Class.forName("com.mysql.jdbc.Driver"); 
java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/project","root","toor"); 
Statement st= con.createStatement(); 
ResultSet rs; 
int i=st.executeUpdate("insert into student values ('"+userr+"','"+age+"','"+mnum+"','"+fname+"','"+mname+"','"+addr+"','"+cid+"','"+uid+"','"+brch+"','"+sem+"','"+b10th+"','"+p10th+"','"+b12th+"','"+p12th+"','"+t1+"','"+c1+"','"+ds1+"','"+de1+"','"+t2+"','"+c2+"','"+ds2+"','"+de2+"','"+jid+"','"+ja+"','"+jt+"','"+js+"')"); 
}
catch(Exception e){ out.println(e.getMessage()); }
Class.forName("com.mysql.jdbc.Driver"); 
java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/project","root","toor"); 
String userrr=request.getParameter("user"); 
Statement st= con.createStatement(); 
ResultSet rs1=st.executeQuery("select * from student where user='"+userrr+"'"); 
if(rs1.next()){
%><script type="text/javascript" >
window.open("stu.html","_self");
</script>
<%} else {%><script type="text/javascript" >
alert("not registered");
window.open("stureg.html","_self");
</script>
<% }
%>
</body>
</html>