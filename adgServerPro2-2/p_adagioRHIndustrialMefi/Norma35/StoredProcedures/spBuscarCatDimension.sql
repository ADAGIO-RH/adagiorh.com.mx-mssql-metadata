USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Norma35].[spBuscarCatDimension](
    @IDDominio int
)
as BEGIN
    select distinct 
        D.IDDimension, 
        D.Descripcion 
    from  Norma35.tblCatPreguntas P
         inner join Norma35.tblcatDimensiones D on P.IDDimension = D.IDDimension
         where IDDominio= @IDDominio

          
END
GO
