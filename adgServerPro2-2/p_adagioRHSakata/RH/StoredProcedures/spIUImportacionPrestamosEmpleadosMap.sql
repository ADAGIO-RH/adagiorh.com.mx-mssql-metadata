USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUImportacionPrestamosEmpleadosMap]  
(  
   @dtImportacion [Nomina].[dtPrestamosImportacion] READONLY    
 ,@IDUsuario int  
)  
AS  
BEGIN
declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	)
    declare @SalarioMinimo decimal (18,2)
	
	SELECT TOP 1 @SalarioMinimo = SalarioMinimo FROM Nomina.tblSalariosMinimos WHERE Fecha <= GETDATE() ORDER BY Fecha DESC;

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos correctos', 1),
		(2, 'La clave del empleado no existe', 0),
        (3, 'Tipo Prestamo no existe', 0),
        (4,'Estatus Prestamo no existe',0),
        (5,'El monto del préstamo no puede ser menor o igual a 0',0),
		(6,'El Importe a descontar no puede ser menor o igual a 0',0),
		(7,'Este Empleado gana el salario mímino, por lo que no es apto para un prestamo.',1),
		(8,'El Monto del prestamo excede el limite permitido por la ley de un Mes de sueldo.',1),
		(9,'El empleado no vigente.',0)
		



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
        ,E.CodigoTipoPrestamo
		,ISNULL(tp.IDTipoPrestamo,0) as IDTipoPrestamo  
        ,E.TipoPrestamo       
		,ISNULL(EP.IDEstatusPrestamo,0) as IDEstatusPrestamo  
        ,E.EstatusPrestamo       
		,E.MontoPrestamo
		,cast(E.CuotasPrestamos as int) AS [CantidadCuotas]
		,CAST(ISNULL(E.MontoPrestamo / NULLIF(E.CuotasPrestamos, 0), 0) AS decimal(18,2)) as [CuotasPrestamos]
		,E.[Descripcion]  	
        ,cast(isnull(E.[FechaInicioPago],'9999-12-31') as DATE) as [FechaInicioPago]    
	    ,IDMensaje =  							
					case when isnull((Select TOP 1 IDEmpleado from RH.tblEmpleadosMaster Where ClaveEmpleado = E.[ClaveEmpleado] ),0) = 0 then '2,' else '' END                            
					+case when isnull((Select TOP 1 IDTipoPrestamo from Nomina.tblCatTiposPrestamo Where Codigo = E.[CodigoTipoPrestamo] ),0) = 0 then '3,' else '' END
					+case when isnull((Select TOP 1 IDEstatusPrestamo from Nomina.tblCatEstatusPrestamo Where Descripcion = E.[EstatusPrestamo] ),0) = 0 then '4' else '' END
					+case when E.MontoPrestamo=0 then '5' else '' END
					+case when E.CuotasPrestamos=0 then '6' else '' END
					+case when (SELECT TOP 1 SalarioDiario FROM RH.tblEmpleadosMaster WHERE ClaveEmpleado = E.[ClaveEmpleado]) * 30.4 <= @SalarioMinimo * 30.4 THEN '7' else'' end
					+case when E.MontoPrestamo > (SELECT TOP 1 SalarioDiario FROM RH.tblEmpleadosMaster WHERE ClaveEmpleado = E.[ClaveEmpleado]) * 30.4 THEN '8,' else'' end
					+case when isnull((Select TOP 1 Vigente from RH.tblEmpleadosMaster Where ClaveEmpleado = E.[ClaveEmpleado] ),0) = 0 then '9' else '' END      
							

	from @dtImportacion E  
	  left join Nomina.tblCatEstatusPrestamo EP on EP.Descripcion COLLATE Cyrillic_General_CI_AI = e.EstatusPrestamo COLLATE Cyrillic_General_CI_AI
	  left join Nomina.tblCatTiposPrestamo TP on TP.Codigo = e.CodigoTipoPrestamo
	WHERE isnull(E.ClaveEmpleado,'') <>''   

		) info 
	order by info.ClaveEmpleado
END
GO
