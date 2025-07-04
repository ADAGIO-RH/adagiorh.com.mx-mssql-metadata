USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spAnteriorItemWizard](
	@Url varchar(max)
	,@IDProyecto int  
	,@IDUsuario int  
) as 
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Evaluacion360].[spAnteriorItemWizard]',
		@Tabla		varchar(max) = '[Evaluacion360].[tblDetalleWizardUsuario]',
		@Accion		varchar(20)	= 'WIZARD ANTERIOR',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;
	declare 
		--@Url varchar(max) =  '#/Evaluacion360/Proyectos/Index'
				--'#/Evaluacion360/Proyectos/relacionesmasivas?id=32'
				--'#/Evaluacion360/Proyectos/seleccionColaboradores?id=32'
				--'#/Evaluacion360/EscalaValoracionProyecto?id=32'
				--'#/Evaluacion360/Proyectos/Configuracion?id=28'
		--,@IDProyecto int = 32
		--,@IDUsuario int = 1
		@IDWizardUsuario int = 0
		,@IDWizardItemActual int
		,@OrderWizardItemActual int
		,@ItemActualCompleto bit
		,@UrlAnterior varchar(max)
		,@IDDetalleWizardUsuario int = 0
		,@dtEvaluadoresRequeridos [Evaluacion360].[dtEvaluadoresRequeridos]
		,@IDItemCompetencias int = 4
	;
	
	if object_id('tempdb..#tempRespuesta') is not null drop table #tempRespuesta;

	create table #tempRespuesta(
		Avanzar bit not null
		,Mensaje varchar(255)
	--	,Redirect bit
		,[Url] varchar(max) 
		,IDWizardUsuario int
		,IDWizardItem int
	);

	select @Url=SUBSTRING(@url,
		CHARINDEX('/',@Url) +1,
		case when CHARINDEX('?',@Url) > 0 then CHARINDEX('?',@Url) - CHARINDEX('/',@Url) -1 else len(@url) end)

	select @IDWizardItemActual = IDWizardItem
		,@OrderWizardItemActual = Orden
	from [Evaluacion360].[tblCatWizardItem] with (nolock)
	where lower([Url]) = lower(@Url)

	select @IDWizardUsuario = IDWizardUsuario
	from [Evaluacion360].[tblWizardsUsuarios] with (nolock)
	where IDProyecto = @IDProyecto --and IDUsuario = @IDUsuario
	
	-- ItemSiguiente
	select top 1 @UrlAnterior = case 
				when cw.IDWizardItem = @IDItemCompetencias then [Url]+N'?tiporeferencia=1&idreferencia='+cast(@IDProyecto as varchar(10))
				WHEN cw.IDWizardItem = 1 THEN 'Evaluacion360/Proyectos/Configuracion'
			else [Url] end
	from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock)
		join  [Evaluacion360].[tblCatWizardItem] cw  with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	where IDWizardUsuario = @IDWizardUsuario and cw.Orden < @OrderWizardItemActual
	ORDER BY cw.Orden desc

	insert #tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
	select 1,'',@UrlAnterior,@IDWizardUsuario,@IDWizardItemActual

	select @InformacionExtra = a.JSON 
	from #tempRespuesta b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra		= @InformacionExtra

	select * from #tempRespuesta; return;
GO
