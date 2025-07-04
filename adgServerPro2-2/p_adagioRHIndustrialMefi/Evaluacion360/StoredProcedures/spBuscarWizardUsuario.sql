USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************l*************************************************************** 
** Descripción		: Buscar un Wizard de Usuario
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-20
** Paremetros		:   
						@IDWizardUsuario int = 0
						,@SoloCompletos bit = null
						,@IDUsuario int           
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2021-08-12			ANEUDY ABREU	- Validación del permiso @VER_TODAS_LAS_PRUEBAS
									- Se agregó el campo Usuario


[Evaluacion360].[spBuscarWizardUsuario] 
	@IDWizardUsuario  = 0
--	,@SoloCompletos  = 1
	,@IDUsuario = 1
***************************************************************************************************/
 CREATE proc [Evaluacion360].[spBuscarWizardUsuario] (
	@IDWizardUsuario int = 0
	,@SoloCompletos bit = null
	,@IDUsuario int
 ) as

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
	
	if exists(
		select top 1 1 
		from [Seguridad].[vwPermisosEspecialesUsuarios] pes with (nolock)	
			join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'VER_TODAS_LAS_PRUEBAS')
	begin
		set @VER_TODAS_LAS_PRUEBAS = 1
	end;

	select 
		wu.IDWizardUsuario
		,wu.IDProyecto
		,cp.Nombre Proyecto
		,isnull(cp.Descripcion,'SIN DESCRIPCIÓN') as DescripcionProyecto
		,wu.IDUsuario
		,coalesce(u.Nombre, '')+ ' '+ coalesce(u.Apellido, '') as Usuario
		,wu.Completo
		,isnull([Evaluacion360].[fnBuscarProgresoWizardUsuario](wu.IDWizardUsuario),0.0) as Progreso
		,wu.FechaHora 
		,LEFT(DATENAME(WEEKDAY,isnull(wu.FechaHora,getdate())),3) + ' ' +
			CONVERT(VARCHAR(6),isnull(wu.FechaHora,getdate()),106) 
			+ ' '+convert(varchar(4),datepart(year,isnull(wu.FechaHora,getdate()) ))
			FechaHoraStr
		,ctp.IDTipoProyecto
		,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoProyecto
	from [Evaluacion360].[tblWizardsUsuarios] wu with (nolock)
		join [Evaluacion360].[tblCatProyectos] cp with (nolock) on wu.IDProyecto = cp.IDProyecto
		join [Evaluacion360].[tblCatTiposProyectos] ctp on ctp.IDTipoProyecto = isnull(cp.IDTipoProyecto, 1)
		left join [Evaluacion360].[tblAdministradoresProyecto] ap on ap.IDProyecto = cp.IDProyecto and ap.IDUsuario = @IDUsuario
		join [Seguridad].[tblUsuarios] u on u.IDUsuario = wu.IDUsuario
	where (wu.IDWizardUsuario = @IDWizardUsuario or @IDWizardUsuario = 0)
		and (wu.IDUsuario = case 
								when @VER_TODAS_LAS_PRUEBAS = 1 then wu.IDUsuario 
								when ap.IDAdministradorProyecto is not null then wu.IDUsuario
							else @IDUsuario end
			)
		and (wu.Completo = isnull(@SoloCompletos,0))
	order by wu.FechaHora asc
GO
