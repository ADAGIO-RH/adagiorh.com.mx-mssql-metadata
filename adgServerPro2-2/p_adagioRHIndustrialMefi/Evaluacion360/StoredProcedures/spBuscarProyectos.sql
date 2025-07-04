USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca proyectos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 

 Si se modifica el result set de este sp será necesario modificar también los siguientes SP's:

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-12			Aneudy Abreu		Se agregó el campo IDWizardUsuario
2019-06-04			Aneudy Abreu		Se agregó la validación de la configuración 'VerPruebasDeSubordinados'
										la cual permite que el usuario pueda ver las pruebas de sus subordinados.
2019-06-06			Aneudy Abreu		Se agregó el parámetro y validación '@VerTodas'
										el cual permite que el usuario pueda ver todas las pruebas independientemente de quien
										la creó.
2022-12-02			Alejandro Paredes	Se agregaron las columnas Instrucciones e Indicaciones
***************************************************************************************************/

CREATE proc [Evaluacion360].[spBuscarProyectos](
	@IDProyecto int = null
	,@VerTodas bit = 0
	,@IDUsuario int
) as

    SET FMTONLY OFF
	
	begin -- Set Idioma 
 		declare  
			@IDIdioma Varchar(5)
			,@IdiomaSQL varchar(100) = null
		;

		SET DATEFIRST 7;

		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

		select @IdiomaSQL = [SQL]
		from app.tblIdiomas
		where IDIdioma = @IDIdioma

		if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
		begin
			set @IdiomaSQL = 'Spanish' ;
		end
  
		SET LANGUAGE @IdiomaSQL;
	end

	declare 
		@VER_TODAS_LAS_PRUEBAS bit = 0
	;  
	
	--if exists(
	--	select top 1 1 
	--	from Seguridad.tblPermisosEspecialesUsuarios pes with (nolock)	
	--		join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
	--	where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'VER_TODAS_LAS_PRUEBAS')
	--begin
		set @VER_TODAS_LAS_PRUEBAS = 1
	--end;

	if object_id('tempdb..#tempProyectos') is not NULL drop table #tempProyectos;
	declare @tempHistorialEstatusProyectos as table(
		IDEstatusProyecto int,
		IDProyecto int,
		IDEstatus int,
		Estatus varchar(255),
		IDUsuario int, 
		FechaCreacion datetime,
		[ROW] int
	)
	
	if @IDProyecto = 0 set @IDProyecto = null;

	insert @tempHistorialEstatusProyectos
	select 
		tep.IDEstatusProyecto
		,tep.IDProyecto		
		,isnull(tep.IDEstatus,0) AS IDEstatus
		,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus
		,tep.IDUsuario
		,tep.FechaCreacion 
		,ROW_NUMBER()over(partition by tep.IDProyecto 
							ORDER by tep.IDProyecto, tep.FechaCreacion  desc) as [ROW]
	from [Evaluacion360].[tblCatProyectos] tcp with (nolock)
		left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus with (nolock) where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus
	where tcp.IDProyecto = @IDProyecto or @IDProyecto is null
		and (tcp.IDUsuario = case when @VER_TODAS_LAS_PRUEBAS = 1 then tcp.IDUsuario else @IDUsuario end)

	select 
		p.IDProyecto
		,p.Nombre --+' - '+isnull(convert(varchar(50),p.FechaInicio,106),'Fecha sin asignar') as Nombre
		,p.Descripcion
		,isnull(thep.IDEstatus,0) AS IDEstatus
		,isnull(thep.Estatus,'Sin estatus') AS Estatus
		,isnull(p.FechaCreacion,getdate()) as FechaCreacion
		,p.IDUsuario
		--,isnull(u.IDEmpleado,0) as IDEmpleado
		--,u.Cuenta
		,Usuario = case when emp.IDEmpleado is not null then coalesce(emp.Nombre,'')+' '+coalesce(emp.Paterno,'')+' '+coalesce(emp.Materno,'')
					   else coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') END
		,AutoEvaluacion = CASE WHEN EXISTS (SELECT TOP 1 1 
												FROM [Evaluacion360].[tblEvaluadoresRequeridos] 
												WHERE IDProyecto = p.IDProyecto AND IDTipoRelacion = 4) THEN cast(1 as bit) else cast(0 as bit) END
		,isnull(p.TotalPruebasARealizar,0)	 as TotalPruebasARealizar
		,isnull(p.TotalPruebasRealizadas,0)	 as TotalPruebasRealizadas
		,isnull(p.Progreso,0)				 AS Progreso
		,isnull(p.FechaInicio,'1990-01-01') AS FechaInicio
		,isnull(p.FechaFin,'1990-01-01') AS FechaFin
		,isnull(Calendarizado,cast(0 AS bit)) AS Calendarizado
		,isnull(IDTask,0) AS IDTask
		,isnull(IDSchedule,0) AS IDSchedule
		,isnull(wu.IDWizardUsuario,0) AS IDWizardUsuario
		,p.Introduccion
		,p.Indicacion
		,ctp.IDTipoProyecto
		,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoProyecto
	from [Evaluacion360].[tblCatProyectos] p with (nolock)
		join [Evaluacion360].[tblCatTiposProyectos] ctp on ctp.IDTipoProyecto = isnull(p.IDTipoProyecto, 1)
		join [Seguridad].[TblUsuarios] u with (nolock) on p.IDUsuario = u.IDUsuario
		join [Evaluacion360].[tblWizardsUsuarios] wu with (nolock) on wu.IDProyecto = p.IDProyecto
		left join [RH].[tblEmpleados] emp with (nolock) on u.IDEmpleado = emp.IDEmpleado
		LEFT JOIN @tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1
	where (p.IDProyecto = @IDProyecto or @IDProyecto is null)
		and (p.IDUsuario = case when @VER_TODAS_LAS_PRUEBAS = 1 then p.IDUsuario else @IDUsuario end)
	order by p.Nombre asc

	IF @IDProyecto IS NOT NULL 
	exec [Evaluacion360].[spBuscarConfiguracionAvanzadaProyecto] @IDProyecto = @IDProyecto
GO
