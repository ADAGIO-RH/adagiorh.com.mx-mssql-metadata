USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarUsuariosListado] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare 
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoVigente int
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)

	
	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))




	if(@IDTipoVigente = 1)
	BEGIN
		
		select Usuario.cuenta as CUENTA
			  ,CONCAT(Usuario.Apellido, ' ', usuario.Nombre) as NOMBRE
			  ,Perfil.Descripcion as [PERFIL PERMISOS]
			  ,usuario.Email as [EMAIL]
			  ,e.ClaveEmpleado as [COLABORADOR]
		FROM Seguridad.tblusuarios usuario with (nolock)
			inner join Seguridad.tblcatperfiles perfil with (nolock)
				on perfil.idperfil = usuario.idperfil
			left join rh.tblempleados e with (nolock)
				on e.idempleado = usuario.idempleado
		where usuario.cuenta between @ClaveEmpleadoInicial and @ClaveEmpleadoFinal and usuario.Activo = 1
		Order by usuario.Cuenta
			

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		
		select Usuario.cuenta as CUENTA
			  ,CONCAT(Usuario.Apellido, ' ', usuario.Nombre) as NOMBRE
			  ,Perfil.Descripcion as [PERFIL PERMISOS]
			  ,usuario.Email as [EMAIL]
			  ,e.ClaveEmpleado as [COLABORADOR]
		FROM Seguridad.tblusuarios usuario with (nolock)
			inner join Seguridad.tblcatperfiles perfil with (nolock)
				on perfil.idperfil = usuario.idperfil
			left join rh.tblempleados e with (nolock)
				on e.idempleado = usuario.idempleado
		where usuario.cuenta between @ClaveEmpleadoInicial and @ClaveEmpleadoFinal and usuario.Activo = 0
		Order by usuario.Cuenta

	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
		select Usuario.cuenta as CUENTA
			  ,CONCAT(Usuario.Apellido, ' ', usuario.Nombre) as NOMBRE
			  ,Perfil.Descripcion as [PERFIL PERMISOS]
			  ,usuario.Email as [EMAIL]
			  ,e.ClaveEmpleado as [COLABORADOR]
		FROM Seguridad.tblusuarios usuario with (nolock)
			inner join Seguridad.tblcatperfiles perfil with (nolock)
				on perfil.idperfil = usuario.idperfil
			left join rh.tblempleados e with (nolock)
				on e.idempleado = usuario.idempleado
		where usuario.cuenta between @ClaveEmpleadoInicial and @ClaveEmpleadoFinal
		Order by usuario.Cuenta
	END
END
GO
