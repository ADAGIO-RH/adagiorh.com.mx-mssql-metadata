USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Seguridad].[vwPermisosUsuariosReportes]
AS

Select 
 reportes.IDReporteBasico
,reportes.IDAplicacion
,perfil.IDPerfil
,perfil.Descripcion AS Perfil
,usuarios.IDUsuario
,usuarios.Cuenta as Usuario
,prp.Acceso as AccesoPerfil
,prp.IDPermisoReportePerfil
,pru.Acceso as AccesoUsuario
,pru.IDPermisoReporteUsuario
,case when ISNULL(pru.PermisoPersonalizado,0) = 1 then ISNULL(pru.Acceso,0) else ISNULL(prp.Acceso,0) end as Acceso
from Reportes.tblCatReportesBasicos reportes
cross join Seguridad.tblCatPerfiles perfil
cross join Seguridad.tblUsuarios usuarios
left join Seguridad.tblPermisosReportesPerfiles prp on prp.IDReporteBasico = reportes.IDReporteBasico and prp.idperfil = perfil.idperfil
left join Seguridad.tblPermisosReportesUsuarios pru on pru.IDReporteBasico = reportes.IDReporteBasico and pru.IDUsuario = usuarios.IDUsuario
WHERE usuarios.IDPerfil = perfil.IDPerfil
GO
