USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUImportacionJefesEmpleadosMap]  
(  
   @dtEmpleados [RH].[dtJefesEmpleadosImportacionMap] READONLY  
  ,@IDUsuario int
)  
AS  
BEGIN
declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	)
    

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos correctos', 1),
		(2, 'La clave del empleado no existe', 0),
        (3, 'La clave del jefe no existe', 0),
        (4,'La relacion jefe empleado ya existe',0)


	select 
		info.*,
        (select m.[Message] as Message, CAST(m.Valid as bit) as Valid
        from @tempMessages m 
        where ID in (SELECT ITEM from app.split(info.IDMensaje,',')) 
        FOR JSON PATH) as Msg,
		CAST(
		CASE WHEN EXISTS (  (select m.[Valid] as Message
        from @tempMessages m 
        where ID in (SELECT ITEM from app.split(info.IDMensaje,',') ) and Valid = 0 )) THEN 0 ELSE 1 END as bit)  as Valid
from (

	select   
		 isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveEmpleado] ),0) as [IDEmpleado] 
		,E.[ClaveEmpleado] 
        ,isnull((Select TOP 1 NOMBRECOMPLETO from RH.tblEmpleadosMaster Where ClaveEmpleado = E.[ClaveEmpleado] ),'') as [NombreEmpleado] 
        ,isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveJefe] ),0) as [IDJefe] 
		,E.[ClaveJefe]  
		,isnull((Select TOP 1 NOMBRECOMPLETO from RH.tblEmpleadosMaster Where ClaveEmpleado = E.[Clavejefe] ),'') as [NombreJefe] 
	    ,IDMensaje =  							
							 case when isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveEmpleado] ),0) = 0 then '2,' else '' END                            
							+case when isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveJefe] ),0) = 0 then '3,' else '' END
                            +case when (Select top 1 1 from rh.tblJefesEmpleados je 
                                            join rh.tblEmpleados ee on je.IDEmpleado = ee.IDEmpleado
                                            join rh.tblEmpleados ej on je.IDJefe = ej.IDEmpleado
                                            where ee.ClaveEmpleado = e.ClaveEmpleado and ej.ClaveEmpleado = e.ClaveJefe)  = 1 then '4' else '' end                            
							

	from @dtEmpleados E  
	WHERE isnull(E.ClaveEmpleado,'') <>''   

		) info 
	order by info.ClaveEmpleado
END
GO
