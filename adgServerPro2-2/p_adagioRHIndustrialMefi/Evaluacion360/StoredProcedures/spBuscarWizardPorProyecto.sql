USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Evaluacion360].[spBuscarWizardPorProyecto]( 
	@IDProyecto int 
	,@IDUsuario int 
)  as
	declare  
		@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;

	select wu.IDWizardUsuario
		,wu.IDProyecto
		,cp.Nombre +' - '+isnull(convert(varchar(50),cp.FechaInicio,106),'Fecha sin asignar') as Proyecto
		,isnull(cp.Descripcion,'SIN DESCRIPCIÓN') as DescripcionProyecto
		,wu.IDUsuario
		,wu.Completo
		,[Evaluacion360].[fnBuscarProgresoWizardUsuario](wu.IDWizardUsuario) as Progreso
		,wu.FechaHora 
		,LEFT(DATENAME(WEEKDAY,isnull(wu.FechaHora,getdate())),3) + ' ' +
			CONVERT(VARCHAR(6),isnull(wu.FechaHora,getdate()),106) 
			+ ' '+convert(varchar(4),datepart(year,isnull(wu.FechaHora,getdate()) ))
			FechaHoraStr
		,ctp.IDTipoProyecto
	from [Evaluacion360].[tblWizardsUsuarios] wu with (nolock)
		join [Evaluacion360].[tblCatProyectos] cp with (nolock) on wu.IDProyecto = cp.IDProyecto
		join [Evaluacion360].[tblCatTiposProyectos] ctp on ctp.IDTipoProyecto = isnull(cp.IDTipoProyecto, 1)
	where (wu.IDProyecto = @IDProyecto)
	order by wu.FechaHora asc
GO
