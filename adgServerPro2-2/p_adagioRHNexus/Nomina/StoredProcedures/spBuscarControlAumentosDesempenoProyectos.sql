USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca proyectos asociados a un aumento por desempeño
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2024-12-27
** Paremetros		:              

** DataTypes Relacionados: 

 Si se modifica el result set de este sp será necesario modificar también los siguientes SP's:

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   proc [Nomina].[spBuscarControlAumentosDesempenoProyectos](
	@IDControlAumentosDesempeno int 	
	,@IDUsuario int
) as

    SET FMTONLY OFF
	
	BEGIN -- Set Idioma 
 		DECLARE  
			@IDIdioma VARCHAR(5)
			,@IdiomaSQL VARCHAR(100) = null
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

	DECLARE 
		@VER_TODAS_LAS_PRUEBAS bit = 0
	;  
	
	
    SET @VER_TODAS_LAS_PRUEBAS = 1
	
	IF OBJECT_ID('tempdb..#tempProyectos') IS NOT NULL DROP TABLE #tempProyectos;
	declare @tempHistorialEstatusProyectos as table(
		IDEstatusProyecto int,
		IDProyecto int,
		IDEstatus int,
		Estatus varchar(255),
		IDUsuario int, 
		FechaCreacion datetime,
		[ROW] int
	)
	
	

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

	SELECT 
		 cadp.IDControlAumentosDesempenoProyecto
        ,cadp.IDControlAumentosDesempeno        
        ,p.IDProyecto
		,p.Nombre 
		,p.Descripcion
		,isnull(thep.IDEstatus,0) AS IDEstatus
		,isnull(thep.Estatus,'Sin estatus') AS Estatus
		,isnull(p.FechaCreacion,getdate()) as FechaCreacion
		,p.IDUsuario		
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
	FROM [Evaluacion360].[tblCatProyectos] p WITH (NOLOCK)
		INNER JOIN [Evaluacion360].[tblCatTiposProyectos] ctp ON ctp.IDTipoProyecto = ISNULL(p.IDTipoProyecto, 1)
		INNER JOIN [Seguridad].[TblUsuarios] u WITH (NOLOCK) ON p.IDUsuario = u.IDUsuario
		INNER JOIN [Evaluacion360].[tblWizardsUsuarios] wu WITH (NOLOCK) ON wu.IDProyecto = p.IDProyecto
		LEFT JOIN [RH].[tblEmpleados] emp WITH (NOLOCK) ON u.IDEmpleado = emp.IDEmpleado
		LEFT JOIN @tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1	
        INNER JOIN [Nomina].[tblControlAumentosDesempenoProyectos] cadp ON cadp.IDProyecto = p.IDProyecto AND cadp.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
	ORDER BY p.Nombre ASC
GO
