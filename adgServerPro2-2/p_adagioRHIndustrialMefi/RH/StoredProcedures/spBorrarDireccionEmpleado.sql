USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar la dirección del Empleado>
** Autor			: <Aneudy Abreu>
** Email			: <aneudy.abreu@adagio.com.mx>
** FechaCreacion	: <1/1/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
2018-07-06		Jose Roman			Se agrega Procedure para proceso de Sincronizacion
***************************************************************************************************/

CREATE PROCEDURE [RH].[spBorrarDireccionEmpleado]
(
	@IDDireccionEmpleado int,
	@IDUsuario int
)
AS
BEGIN
    declare @IDEmpleado int = 0;

		DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].tblDireccionEmpleado b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDDireccionEmpleado = @IDDireccionEmpleado	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDireccionEmpleado]','[RH].[spBorrarDireccionEmpleado]','DELETE','',@OldJSON




    select @IDEmpleado=IDEmpleado
    from RH.tblDireccionEmpleado with (nolock)
    where IDDireccionEmpleado = @IDDireccionEmpleado	

    Delete RH.tblDireccionEmpleado 
    where IDDireccionEmpleado = @IDDireccionEmpleado

    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null
	   drop table #tblTempHistorial1;

    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null
	   drop table #tblTempHistorial2;

    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]
    INTO #tblTempHistorial1
    FROM RH.tblDireccionEmpleado with (nolock)
    WHERE IDEmpleado = @IDEmpleado
    order by FechaIni asc

    select 
	   t1.IDDireccionEmpleado
	   ,t1.IDEmpleado	  
	   ,t1.FechaIni
	   ,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni) 
				else '9999-12-31' end 
    INTO #tblTempHistorial2
    from #tblTempHistorial1 t1
	   left join (select * 
				from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)

    update [TARGET]
    set 
	   [TARGET].FechaFin = [SOURCE].FechaFin
    FROM RH.tblDireccionEmpleado as [TARGET]
	   join #tblTempHistorial2 as [SOURCE] on [TARGET].IDDireccionEmpleado = [SOURCE].IDDireccionEmpleado		
	
	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
END
GO
