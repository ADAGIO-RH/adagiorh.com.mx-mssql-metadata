USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar un Wizard de Usuario
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-20
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?



[Evaluacion360].[spBuscarWizardUsuario] 
	@IDWizardUsuario  = 0
	,@SoloCompletos  = 1
	,@IDUsuario = 1

***************************************************************************************************/
 CREATE proc [Evaluacion360].[spBuscarWizardUsuario] (
	@IDWizardUsuario int = 0
	,@SoloCompletos bit = null
	,@IDUsuario int
 ) as

 	declare  
		@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		;

	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
	from Seguridad.tblUsuarios u
		Inner join App.tblPreferencias p
			on u.IDPreferencia = p.IDPreferencia
		Inner join App.tblDetallePreferencias dp
			on dp.IDPreferencia = p.IDPreferencia
		Inner join App.tblCatTiposPreferencias tp
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario
			and tp.TipoPreferencia = 'Idioma'

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;

	if OBJECT_ID('tempdb..#tempW') is not null drop table #tempW;


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
	from [Evaluacion360].[tblWizardsUsuarios] wu with (nolock)
		join [Evaluacion360].[tblCatProyectos] cp with (nolock) on wu.IDProyecto = cp.IDProyecto
	where (wu.IDWizardUsuario = @IDWizardUsuario or @IDWizardUsuario = 0)
		and wu.IDUsuario = @IDUsuario
		and (wu.Completo = isnull(@SoloCompletos,0))
	order by wu.FechaHora asc


	--select convert(varchar(100),GETDATE(),106)
GO
