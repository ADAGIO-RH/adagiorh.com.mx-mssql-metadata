USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [Nomina].[spBorrarDetalleTablaImpuesto](
    	@IDTablaImpuesto int
        ,@IDUsuario int
) as BEGIN

    delete from [Nomina].[tblDetalleTablasImpuestos]
    where IDTablaImpuesto = @IDTablaImpuesto;

    END
GO
