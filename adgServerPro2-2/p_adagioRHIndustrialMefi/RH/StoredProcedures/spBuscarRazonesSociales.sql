USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarRazonesSociales](
	@IDRazonSocial int = null,
	@IDCliente int = null,
	@IDUsuario int
) AS
BEGIN
	SET FMTONLY OFF;  

	IF OBJECT_ID('tempdb..#TempRazonesSociales') IS NOT NULL DROP TABLE #TempRazonesSociales
    
	select ID   
	Into #TempRazonesSociales  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'RazonesSociales'  
	
	SELECT 
		 C.IDRazonSocial
		,C.RFC
		,C.RazonSocial
		,isnull(C.IDCodigoPostal,0) as IDCodigoPostal
		,CP.CodigoPostal
		,isnull(C.IDEstado,0) as IDEstado
		,'['+E.Codigo+'] '+E.NombreEstado as Estado
		,isnull(C.IDMunicipio,0) as IDMunicipio
		,'['+M.Codigo+'] '+M.Descripcion as Municipio
		,isnull(C.IDColonia,0) as IDColonia
		,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia
		,isnull(C.IDPais,0) as IDPais
		,'['+P.Codigo+'] '+P.Descripcion as Pais
		,C.Calle
		,C.Exterior
		,C.Interior
		,ISNULL(C.IDRegimenFiscal,0) AS IDRegimenFiscal
		,RF.Descripcion as RegimenFiscal
		,ISNULL(C.IDOrigenRecurso,0) AS IDOrigenRecurso
		,OrigenRecurso.Descripcion as OrigenRecurso
		,isnull(C.IDCliente,0) as IDCliente 
		,isnull(C.Comision,0) as Comision
	FROM RH.[tblCatRazonesSociales] C
		LEFT join Sat.tblCatCodigosPostales CP on c.IDCodigoPostal = CP.IDCodigoPostal
		LEFT join Sat.tblCatPaises P on c.IDPais = p.IDPais
		LEFT join Sat.tblCatEstados E on C.IDEstado = E.IDEstado
		LEFT join Sat.tblCatMunicipios M on c.IDMunicipio = m.IDMunicipio
		LEFT join Sat.tblCatColonias CL on c.IDColonia = CL.IDColonia
		Left Join Sat.tblCatRegimenesFiscales RF on C.IDRegimenFiscal = RF.IDRegimenFiscal
		Left Join Sat.tblCatOrigenesRecursos OrigenRecurso on OrigenRecurso.IDOrigenRecurso = C.IDOrigenRecurso
	WHERE (c.IDRazonSocial = @IDRazonSocial) OR (C.IDCliente = @IDCliente or isnull(@IDCliente,0) = 0)
		and (c.IDRazonSocial in  (select ID from #TempRazonesSociales) OR Not Exists(select ID from #TempRazonesSociales))  
	ORDER BY C.RFC ASC
END
GO
