USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReporteDePermisosEspecialesPorUsuario] (
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
           US.Cuenta as [CUENTA]
           ,US.Nombre AS [NOMBRE]
           ,US.Apellido as [APELLIDO]
           ,PER.Descripcion as [PERFIL]
           ,CURL.Descripcion AS [MODULO],
            PE.Descripcion as [DESCRIPCION PERMISO]
           ,CASE
                WHEN ISNULL(PEU.PermisoPersonalizado, 0) = 0 THEN
                    'NO'
                ELSE
                    'SI'
            END AS [¿ES PERSONALIZADO?]
            FROM Seguridad.tblPermisosEspecialesUsuarios PEU
            LEFT JOIN Seguridad.tblUsuarios US ON PEU.IDUsuario=US.IDUsuario
            LEFT JOIN APP.tblCatPermisosEspeciales PE ON PEU.IDPermiso=PE.IDPermiso
            LEFT JOIN APP.tblCatUrls CURL ON PE.IDUrlParent=CURL.IDUrl
            LEFT JOIN APP.tblCatModulos mod on mod.IDModulo=curl.IDModulo
            --LEFT JOIN APP.tblCatAreas ARE on are.IDArea=mod.IDArea
            --LEFT JOIN APP.tblAplicacionAreas APA ON APA.IDArea=ARE.IDArea
            LEFT JOIN RH.tblEmpleadosMaster E ON E.IDEmpleado=US.IDEmpleado
            LEFT JOIN Seguridad.tblCatPerfiles PER ON PER.IDPerfil=US.IDPerfil
            WHERE
            us.Activo = 1
            AND
            (
                ISNULL(e.Vigente, 0) = 1
                OR ISNULL(us.IDEmpleado, 0) = 0
            ) -- and isnull(ppu.PermisoPersonalizado, 0) = 1   
            ORDER BY US.IDUsuario
        END
        ELSE
        BEGIN
            SELECT 
           US.Cuenta as [CUENTA]
           ,US.Nombre AS [NOMBRE]
           ,US.Apellido as [APELLIDO]
           ,PER.Descripcion as [PERFIL]
           ,CURL.Descripcion AS [MODULO],
            PE.Descripcion as [DESCRIPCION PERMISO]
           ,CASE
                WHEN ISNULL(PEU.PermisoPersonalizado, 0) = 0 THEN
                    'NO'
                ELSE
                    'SI'
            END AS [¿ES PERSONALIZADO?],
            CASE WHEN isnull(US.Activo,0)=1 THEN 'SI' ELSE 'NO' END AS [¿ACTIVO?],
            CASE WHEN  isnull(e.Vigente,0)=1 THEN 'SI' ELSE 'NO' END AS [¿BAJA?]
            FROM Seguridad.tblPermisosEspecialesUsuarios PEU
            LEFT JOIN Seguridad.tblUsuarios US ON PEU.IDUsuario=US.IDUsuario
            LEFT JOIN APP.tblCatPermisosEspeciales PE ON PEU.IDPermiso=PE.IDPermiso
            LEFT JOIN APP.tblCatUrls CURL ON PE.IDUrlParent=CURL.IDUrl
            LEFT JOIN APP.tblCatModulos mod on mod.IDModulo=curl.IDModulo
            LEFT JOIN APP.tblCatAreas ARE on are.IDArea=mod.IDArea
            LEFT JOIN APP.tblAplicacionAreas APA ON APA.IDArea=ARE.IDArea
            LEFT JOIN RH.tblEmpleadosMaster E ON E.IDEmpleado=US.IDEmpleado
            LEFT JOIN Seguridad.tblCatPerfiles PER ON PER.IDPerfil=US.IDPerfil
            ORDER BY US.IDUsuario
        END
    

            
END
GO
