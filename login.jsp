<html>
<head>

</head>
<body> 
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%try{
String user=request.getParameter("usr"); 
if (request.getParameter("usr")==null)
{%>
<script type="text/javascript" >
window.open("index.html","_self");
</script>
<% }
else{}
session.putValue("usr",user); 
String stu="stu";
String hr="hr";
String pwd=request.getParameter("pwd"); 
Class.forName("com.mysql.jdbc.Driver"); 
java.sql.Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/project","root","toor"); 
Statement st= con.createStatement(); 
ResultSet rs=st.executeQuery("select * from user where user='"+user+"'"); 
if(rs.next()) 
{ 
if(rs.getString(2).equals(pwd)) 
{   if(rs.getString(6).equals(stu)){
ResultSet rs1=st.executeQuery("select * from student where user='"+user+"'"); 
if(rs1.next()){
%><script type="text/javascript" >
window.open("stu.html","_self");
</script>
<%} else {%><script type="text/javascript" >
window.open("stureg.html","_self");
</script>
<% }
}
else if(rs.getString(6).equals(hr)){
ResultSet rs1=st.executeQuery("select * from company where user='"+user+"'"); 
if(rs1.next()){
%><script type="text/javascript" >
window.open("hr.html","_self");
</script>
<%} else {%><script type="text/javascript" >
window.open("hrreg.html","_self");
</script>
<% }
}else
{ 
} 
} 
else { %>
<script type="text/javascript" >
window.open("index.html","_self");
</script>
<% }
}
else {%>
<script type="text/javascript" >
alert( "Incorrect Username Or PassWord" );
window.open("index.html","_self");

</script>
<% }
}catch(Exception e)
{ out.println(e.getMessage());
}%>
</body>
</html>