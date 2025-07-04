USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE Reportes.spReporteSTPSDC2
(
	@IDProgramaCapacitacion int,
	@IDUsuario int
)
AS
BEGIN
	select 
		p.IDProgramaCapacitacion
		,E.RFC
		,REG.RazonSocial RazonSocialEmpresa
		,E.CURP
		,reg.RegistroPatronal
		,reg.ActividadEconomica
		,reg.Calle
		,reg.Exterior
		,reg.Interior
		,UPPER(est.NombreEstado )as Estado
		,UPPER(muni.Descripcion) as Municipio
		,UPPER(col.NombreAsentamiento) as Colonia
		,UPPER(cp.CodigoPostal)CodigoPostal
		,LOWER( p.Email)Email
		,p.Fax
		,reg.Telefono
		,QtyTrabajadoresConsiderados
		,p.Mujeres
		,p.Hombres
		,p.ObjetivoActualizar
		,p.ObjetivoPrevenir
		,p.ObjetivoIncrementar
		,p.ObjetivoMejorar
		,p.ObjetivoPreparar
		,p.ModalidadEspecificos
		,p.ModalidadComunes
		,p.ModalidadGeneral
		,p.NumeroEstablecimientos
		,p.NumeroEtapas
		,p.FechaInicio
		,p.FechaFin
		,p.RegPatronalesAdicionales
		,UPPER(p.RepresentanteLegal) RepresentanteLegal
		,p.FechaElaboracion
		,UPPER(p.LugarElaboracion) LugarElaboracion
		from STPS.tblProgramasCapacitacionDC2 p	with(nolock)
		inner join RH.tblEmpresa e 	with(nolock)
			on e.IdEmpresa = p.IDEmpresa
		inner join RH.tblCatRegPatronal reg 	with(nolock)
			on reg.IDRegPatronal = p.IDRegPatronal
		left join SAT.tblCatEstados est 	with(nolock)
			on est.IDEstado = reg.IDEstado
		left join SAT.tblCatMunicipios muni 	with(nolock)
			on muni.IDMunicipio = reg.IDMunicipio
		left join SAT.tblCatColonias col 	with(nolock)
			on col.IDColonia = reg.IDColonia
		left join SAT.tblCatCodigosPostales cp 	with(nolock)
			on cp.IDCodigoPostal = reg.IDCodigoPostal
		WHERE IDProgramaCapacitacion = @IDProgramaCapacitacion
END
GO
