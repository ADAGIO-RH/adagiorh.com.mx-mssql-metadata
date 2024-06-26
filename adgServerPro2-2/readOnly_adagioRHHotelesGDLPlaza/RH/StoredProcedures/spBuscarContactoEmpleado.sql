USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBuscarContactoEmpleado]
(
     @IDContactoEmpleado int = 0
    ,@IDEmpleado int = 0
)
AS
BEGIN
		Select 
			CE.IDContactoEmpleado,
			CE.IDEmpleado,
			CE.IDTipoContactoEmpleado,
			TCE.Descripcion as TipoContacto,
			CE.Value,
			TCE.Mask,
			TCE.CssClassIcon,
			isnull(ce.Predeterminado,0) as Predeterminado
		from RH.tblContactoEmpleado CE
			inner join RH.tblCatTipoContactoEmpleado TCE
				on CE.IDTipoContactoEmpleado = TCE.IDTipoContacto
		WHERE (CE.IDEmpleado = @IDEmpleado and @IDContactoEmpleado=0) or (CE.IDContactoEmpleado = @IDContactoEmpleado and @IDEmpleado=0)
		order by ce.IDTipoContactoEmpleado
END
GO
