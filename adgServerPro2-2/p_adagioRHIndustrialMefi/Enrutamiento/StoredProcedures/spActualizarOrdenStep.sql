USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Reorganiza el Orden de los pasos de las Rutas
** Autor			: JOSE ROMANB
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2022-02-08
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROC [Enrutamiento].[spActualizarOrdenStep](
	   @IDRutaStep int 
	   ,@IDCatRuta int
	   ,@OldIndex int  
	   ,@NewIndex int 
	   ,@IDUsuario int = 1
    )
    as

    declare 
		@i int = 1, 
		@Total int = 0,
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Enrutamiento].[spActualizarOrdenStep]',
		@Tabla		varchar(max) = '[Enrutamiento].[tblRutaSteps]',
		@Accion		varchar(20)	= 'UPDATE';

    if OBJECT_ID('tempdb..#tblTempRutaStep') is not null
	   drop table #tblTempRutaStep;


  
		select IDRutaStep, IDCatRuta,IDCatTipoStep,Orden, ROW_NUMBER() over(order by IDRutaStep asc) as ID
		INTO #tblTempRutaStep
		from Enrutamiento.tblRutaSteps
		WHERE IDCatRuta = @IDCatRuta
		

		update rs
		set rs.Orden = t.ID
		from Enrutamiento.tblRutaSteps rs
		inner join #tblTempRutaStep t
		on rs.IDRutaStep = t.IDRutaStep
		and rs.IDCatRuta = t.IDCatRuta
GO
