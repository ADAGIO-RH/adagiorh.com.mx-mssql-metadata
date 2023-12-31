USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReporteDePermisosPorUsuario] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
       ,@IDTipoVigente int
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

    SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

    IF(@IDTipoVigente = 1)
    BEGIN
         SELECT 
            us.Cuenta as [USUARIO],
            us.Nombre as [NOMBRE],
            US.Apellido AS [APELLIDO],
            c.Nombre AS[CONTROLLER],
            cp.Descripcion as [PERFIL],
            u.Descripcion AS [PERMISO],
            tp.Descripcion [TIPO DE PERMISO],
            CASE
                WHEN ISNULL(ppu.PermisoPersonalizado, 0) = 0 THEN
                    'NO'
                ELSE
                    'SI'
            END AS [¿ES PERSONALIZADO?]
        FROM Seguridad.tblPermisosUsuarioControllers ppu
         left   JOIN Seguridad.tblUsuarios us
                ON us.IDUsuario = ppu.IDUsuario
            LEFT JOIN RH.tblEmpleadosMaster e
                ON e.IDEmpleado = us.IDEmpleado
          left  JOIN App.tblCatControllers c
                ON c.IDController = ppu.IDController
         left   JOIN App.tblCatUrls u
                ON u.IDController = c.IDController
         left   JOIN App.tblCatTipoPermiso tp
                ON tp.IDTipoPermiso = ppu.IDTipoPermiso
          left  JOIN Seguridad.tblCatPerfiles cp on cp.IDPerfil=us.IDPerfil
        WHERE u.Tipo = 'V'
            AND us.Activo = 1
            AND
            (
                ISNULL(e.Vigente, 0) = 1
                OR ISNULL(us.IDEmpleado, 0) = 0
            ) -- and isnull(ppu.PermisoPersonalizado, 0) = 1            
        ORDER BY ppu.IDUsuario
    END
  ELSE 
  BEGIN
          SELECT 
            us.Cuenta as [USUARIO],
            us.Nombre as [NOMBRE],
            US.Apellido AS [APELLIDO],
            c.Nombre AS[CONTROLLER],
            cp.Descripcion as [PERFIL],
            u.Descripcion AS [PERMISO],
            tp.Descripcion [TIPO DE PERMISO],
            CASE
                WHEN ISNULL(ppu.PermisoPersonalizado, 0) = 0 THEN
                    'NO'
                ELSE
                    'SI'
            END AS [¿ES PERSONALIZADO?],
            CASE WHEN isnull(US.Activo,0)=1 THEN 'SI' ELSE 'NO' END AS [¿ACTIVO?],
            CASE WHEN  isnull(e.Vigente,0)=1 THEN 'SI' ELSE 'NO' END AS [¿BAJA?]
        FROM Seguridad.tblPermisosUsuarioControllers ppu
            JOIN Seguridad.tblUsuarios us
                ON us.IDUsuario = ppu.IDUsuario
            LEFT JOIN RH.tblEmpleadosMaster e
                ON e.IDEmpleado = us.IDEmpleado
          left  JOIN App.tblCatControllers c
                ON c.IDController = ppu.IDController
          left  JOIN App.tblCatUrls u
                ON u.IDController = c.IDController
           left JOIN App.tblCatTipoPermiso tp
                ON tp.IDTipoPermiso = ppu.IDTipoPermiso
          left  JOIN Seguridad.tblCatPerfiles cp on cp.IDPerfil=us.IDPerfil
        WHERE u.Tipo = 'V'       
        ORDER BY ppu.IDUsuario
  END
  




       
END
GO
