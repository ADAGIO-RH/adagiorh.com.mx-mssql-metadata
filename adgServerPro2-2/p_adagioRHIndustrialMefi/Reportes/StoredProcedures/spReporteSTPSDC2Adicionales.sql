USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE Reportes.spReporteSTPSDC2Adicionales --2,1
(
	@IDProgramaCapacitacion int,
	@IDUsuario int
)
AS
BEGIN

	DECLARE @RFC varchar(max)
	,@RegAdicionales Varchar(max)
	select 
		@RFC =E.RFC
		,@RegAdicionales = p.RegPatronalesAdicionales	
		from STPS.tblProgramasCapacitacionDC2 p	with(nolock)
		inner join RH.tblEmpresa e 	with(nolock)
			on e.IdEmpresa = p.IDEmpresa
		WHERE IDProgramaCapacitacion = @IDProgramaCapacitacion

	select ROW_NUMBER()OVER(ORDER BY reg.IDRegPatronal asc) as RN
		,UPPER(@RFC) as RFC
		,UPPER(reg.RegistroPatronal)RegistroPatronal
		,UPPER(reg.Calle)Calle
		,UPPER(reg.Exterior)Exterior
		,UPPER(reg.Interior)Interior
		,UPPER(est.NombreEstado )as Estado
		,UPPER(muni.Descripcion) as Municipio
		,UPPER(col.NombreAsentamiento) as Colonia
		,UPPER(cp.CodigoPostal)CodigoPostal
	from RH.tblCatRegPatronal reg
	left join SAT.tblCatEstados est 	with(nolock)
			on est.IDEstado = reg.IDEstado
		left join SAT.tblCatMunicipios muni 	with(nolock)
			on muni.IDMunicipio = reg.IDMunicipio
		left join SAT.tblCatColonias col 	with(nolock)
			on col.IDColonia = reg.IDColonia
		left join SAT.tblCatCodigosPostales cp 	with(nolock)
			on cp.IDCodigoPostal = reg.IDCodigoPostal
	where reg.IDRegPatronal in (select item from app.split(@RegAdicionales,','))

END
GO
