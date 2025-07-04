USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Reorganiza el Orden de cálculo de los conceptos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROC [Reclutamiento].[spActualizarOrdenEstatusProceso](
	@IDEstatusProceso int	
	,@OldIndex int			
	,@NewIndex int			
	,@IDUsuario int			
)
as
    declare 
		@i int = 1, 
		@Total int = 0,
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Reclutamiento].[spActualizarOrdenEstatusProceso]',
		@Tabla		varchar(max) = '[Reclutamiento].[tblCatEstatusProceso]',
		@Accion		varchar(20)	= 'UPDATE';

    if OBJECT_ID('tempdb..#tblTempEstatusProcesos')  is not null drop table #tblTempEstatusProcesos;
    if OBJECT_ID('tempdb..#tblTempEstatusProcesos1') is not null drop table #tblTempEstatusProcesos1;

	set @OldJSON = (
		select IDEstatusProceso, Descripcion, Orden
		from Reclutamiento.tblCatEstatusProceso
		for json auto
	) 

    if ((@NewIndex < @OldIndex) or (@OldIndex = 0))
    begin
		  select IDEstatusProceso,Descripcion,Orden, ROW_NUMBER() over(order by Orden asc) as ID
		  INTO #tblTempEstatusProcesos
		  from Reclutamiento.tblCatEstatusProceso
		  where Orden >= @NewIndex and IDEstatusProceso <> @IDEstatusProceso;

		  update Reclutamiento.tblCatEstatusProceso
			 set Orden = @NewIndex
		  where IDEstatusProceso=@IDEstatusProceso

		  while exists(select 1 from #tblTempEstatusProcesos where ID >= @i)
		  begin
			 select @IDEstatusProceso=IDEstatusProceso from #tblTempEstatusProcesos where  ID=@i
			 set @NewIndex = @NewIndex+1

			 update Reclutamiento.tblCatEstatusProceso
				set Orden = @NewIndex
			 where IDEstatusProceso=@IDEstatusProceso
		  
			 select @i=@i+1;
		  end;		
    end else
    begin
		  select IDEstatusProceso,Descripcion,Orden, ROW_NUMBER() over(order by Orden asc) as ID
		  INTO #tblTempEstatusProcesos1
		  from Reclutamiento.tblCatEstatusProceso
		  where (Orden between @OldIndex and @NewIndex) and IDEstatusProceso <> @IDEstatusProceso;

		  update Reclutamiento.tblCatEstatusProceso
			 set Orden = @NewIndex
		  where IDEstatusProceso=@IDEstatusProceso

		  while exists(select 1 from #tblTempEstatusProcesos1 where ID >= @i)
		  begin
			 select @IDEstatusProceso=IDEstatusProceso from #tblTempEstatusProcesos1 where ID=@i

			 update Reclutamiento.tblCatEstatusProceso
				set Orden = @OldIndex
			 where IDEstatusProceso=@IDEstatusProceso

			 set @OldIndex = @OldIndex+1

			 select @i=@i+1;
		  end;
    end;

	select @NewJSON = (
		select IDEstatusProceso, Descripcion, Orden
		from Reclutamiento.tblCatEstatusProceso
		for json auto
	)

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
