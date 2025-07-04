USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarDimensionDeDominio](
    @IDEncuestaEmpleado int
    ,@IDDominio int
)
as BEGIN
    Select  DD.IDDimensionDominio,
			D.Descripcion as Dominio,         
            CD.Descripcion as Dimension
            From  Norma35.TblDimensionesDeDominio DD 
            inner join Norma35.tblcatDimensiones CD on CD.IDDimension = DD.IDDimension
            left join norma35.tblCatDominios D on DD.IDDominio = D.IDDominio
            where IDEncuestaEmpleado=@IDEncuestaEmpleado and DD.IDDominio = @IDDominio
END;
GO
