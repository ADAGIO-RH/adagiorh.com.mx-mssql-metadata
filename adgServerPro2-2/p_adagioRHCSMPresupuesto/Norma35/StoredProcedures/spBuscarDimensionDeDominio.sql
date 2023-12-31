USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Norma35.spBuscarDimensionDeDominio(
    @IDEncuestaEmpleado int
)
as BEGIN
    Select  DD.IDDimensionDominio,
			DD.Dominio ,         
            CD.Descripcion as Dimension
            From  Norma35.TblDimensionesDeDominio DD 
            inner join Norma35.tblcatDimensiones CD on CD.IDDimension = DD.IDDimension
            where IDEncuestaEmpleado=@IDEncuestaEmpleado
END;
GO
