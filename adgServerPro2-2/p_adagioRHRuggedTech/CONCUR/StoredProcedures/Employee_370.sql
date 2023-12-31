USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 [CONCUR].[Employee_370] 
*/

CREATE PROCEDURE  [CONCUR].[Employee_370]   
AS    
BEGIN 

    DECLARE 
    @empleados [RH].[dtEmpleados]   


    insert into @empleados                  
    Select * from RH.tblEmpleadosMaster


	DECLARE 		
    @IDTipoContactoEmail int,
    @IDActiveConcur int,
    @IDSupervisorConcur int ,
    @IDEmployee int
	;

    if object_id('tempdb..#tempHeader') is not null drop table #tempHeader;    
	create table #tempHeader(Respuesta nvarchar(max));    
  
	insert into #tempHeader(Respuesta)  
	select     
		  replace([App].[fnAddString](3,'100','',2),' ','')--Transaction Type 
        + ','
		+ replace([App].[fnAddString](1,'0','',2),' ','') --Error Threshold
        + ','
		+ replace([App].[fnAddString](7,'Welcome','',2),' ','') --Password Generation
        + ','
		+ replace([App].[fnAddString](6,'UPDATE','',2),' ','') --Existing Record Handling
        + ','
        + replace([App].[fnAddString](4,'EN','',2),' ','') -- Language Code
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','') -- Validate Expense Group
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','') -- Validate Payment Group


    Set @IDTipoContactoEmail = (Select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL CORPORATIVO')
    Set @IDActiveConcur = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'CONCURACTIVE')
    Set @IDSupervisorConcur = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'SUPERVISORID')
    set @IDEmployee = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'SUCCESSFACTORID')


    if object_id('tempdb..#tempBody') is not null drop table #tempBody;    
	create table #tempBody(Respuesta nvarchar(max));  

    insert into #tempBody(Respuesta)
    select     
          replace([App].[fnAddString](3,'370','',2),' ','')
        + ','
        + replace([App].[fnAddString](48,ISNULL(employee.Valor,'UNDEFINED'),'',2),' ','')--2. Employee ID
        + ',' 
        + replace([App].[fnAddString](1,'N','',2),' ','') --3. Statement Report User
        + ','
        + replace([App].[fnAddString](1,'N','',2),' ','')--4. Statement Report Approver
        + ','
        + replace([App].[fnAddString](48,ISNULL(supervisorJefe.Valor,'UNDEFINED'),'',2),' ','')--5. Employee ID ofthe employee's Statement Report Approver
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--6. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--7. Future Use. 
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--8. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--9. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--10. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--11. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--12. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--13. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--14. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--15. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--16. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--17. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--18. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--19. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--20. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--21. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--22. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--23. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--24. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--25. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--26. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--27. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','')--28. Future Use.
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','') --29. Future Use. 
        + ','
        + replace([App].[fnAddString](48,'','',2),' ','') --30. Future Use. 
        as Result
        
	FROM @empleados e 
     Inner join rh.tblDatosExtraEmpleados active on active.IDEmpleado = e.IDEmpleado and active.IDDatoExtra = @IDActiveConcur
     Left join rh.tblDatosExtraEmpleados supervisor on supervisor.IDEmpleado = e.IDEmpleado and supervisor.IDDatoExtra = @IDSupervisorConcur
     Left join rh.tblDatosExtraEmpleados employee on employee.IDEmpleado = e.IDEmpleado and employee.IDDatoExtra = @IDEmployee
     Left Join rh.tblJefesEmpleados Subor on Subor.IDEmpleado = e.IDEmpleado
     left join rh.tblDatosExtraEmpleados supervisorJefe on supervisorJefe.IDEmpleado = subor.IDJefe and supervisor.IDDatoExtra = @IDEmployee
   
    Where IDCliente = 1 and active.Valor = 'TRUE'



    Select * from #tempHeader
    Union all 
    Select * from #tempBody

END

GO
