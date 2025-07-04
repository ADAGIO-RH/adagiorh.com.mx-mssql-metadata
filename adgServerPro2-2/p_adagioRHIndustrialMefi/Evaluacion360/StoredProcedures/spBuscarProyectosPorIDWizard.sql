USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca un proyecto asociado a un Wizard
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-04-12
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
 
CREATE proc [Evaluacion360].[spBuscarProyectosPorIDWizard](
	@IDWizard int
	,@IDUsuario int
) as

	declare @IDProyecto int 
	;

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

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
	
	if object_id('tempdb..#tempHistorialEstatusProyectos') is not NULL
			drop table #tempHistorialEstatusProyectos;
	
	select @IDProyecto = IDProyecto
	from Evaluacion360.tblWizardsUsuarios
	where IDWizardUsuario = @IDWizard

	select 
		tep.IDEstatusProyecto
		,tep.IDProyecto
		,isnull(tep.IDEstatus,0) AS IDEstatus
		,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus
		,tep.IDUsuario
		,tep.FechaCreacion 
		,ROW_NUMBER()over(partition by tep.IDProyecto 
							ORDER by tep.IDProyecto, tep.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusProyectos
	from [Evaluacion360].[tblCatProyectos] tcp with (nolock)
		left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus
	where tcp.IDProyecto = @IDProyecto or @IDProyecto is null

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
		,isnull(Calendarizado,cast(0 AS bit))			 AS Calendarizado
		,isnull(IDTask,0)					AS IDTask
		,isnull(IDSchedule,0) AS IDSchedule
		,isnull(wu.IDWizardUsuario,0) AS IDWizardUsuario
		,ctp.IDTipoProyecto
		,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoProyecto
	from [Evaluacion360].[tblCatProyectos] p
		join [Evaluacion360].[tblCatTiposProyectos] ctp on ctp.IDTipoProyecto = isnull(p.IDTipoProyecto, 1)
		join [Seguridad].[TblUsuarios] u on p.IDUsuario = u.IDUsuario
		join [Evaluacion360].[tblWizardsUsuarios] wu on wu.IDProyecto = p.IDProyecto
		left join [RH].[tblEmpleados] emp on u.IDEmpleado = emp.IDEmpleado
		LEFT JOIN #tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1
	where p.IDProyecto = @IDProyecto and p.IDUsuario = @IDUsuario
	Order by thep.IDEstatus asc
GO
