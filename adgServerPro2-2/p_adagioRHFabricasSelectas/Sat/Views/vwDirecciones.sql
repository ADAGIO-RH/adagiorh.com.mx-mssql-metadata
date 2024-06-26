USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW  SAT.vwDirecciones
WITH SCHEMABINDING
AS

	select 
		    isnull(P.IDPais,0) as IDPais,
			UPPER(P.Descripcion) COLLATE DATABASE_DEFAULT as Pais,
			isnull(E.IDEstado,0) as IDEstado,
			UPPER(E.NombreEstado) COLLATE DATABASE_DEFAULT as Estado,
			isnull(M.IDMunicipio,0) as IDMunicipio,
			UPPER(M.Descripcion) COLLATE DATABASE_DEFAULT as Municipio,
			isnull(C.IDColonia,0) as IDColonia,
			UPPER(C.NombreAsentamiento) COLLATE DATABASE_DEFAULT as Colonia,
			isnull(CP.IDCodigoPostal,0) as IDCodigoPostal,
			CP.CodigoPostal,
			isnull(cp.IDLocalidad,0) as IDLocalidad
	from Sat.tblCatColonias C  
	 inner join Sat.tblCatCodigosPostales CP 
		on C.IDCodigoPostal = CP.IDCodigoPostal
	 INNER JOIN Sat.tblCatEstados E 
		on E.IDEstado = CP.IDEstado
	INNER JOIN Sat.tblCatMunicipios M 
		on isnull(CP.IDMunicipio,0) = ISNULL(M.IDMunicipio,0)
		and ISNULL(M.IDEstado,0) = ISNULL(E.IDEstado,0)
	INNER JOIN Sat.tblCatPaises P 
		on isnull(P.IDPais,0) = ISNULL(E.IDPais,0)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
CREATE UNIQUE CLUSTERED INDEX [idx_SAtVwDirecciones_IDColonia] ON [Sat].[vwDirecciones]
(
	[IDColonia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
