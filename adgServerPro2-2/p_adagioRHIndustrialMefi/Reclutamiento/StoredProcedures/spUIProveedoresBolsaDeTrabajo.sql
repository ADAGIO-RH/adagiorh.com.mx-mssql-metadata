USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-22
-- Description:	Procedimiento para crear/Actualizar Proveedores de Bolsa de trabajo
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spUIProveedoresBolsaDeTrabajo]
	@IDProveedorBolsaDeTrabajo int = 0,
	@Nombre varchar(50),
	@StatusProveedor tinyint,
	@IDUsuario int
AS
BEGIN
	
	if( @IDProveedorBolsaDeTrabajo = 0 )
	begin
		insert into [Reclutamiento].[tblProveedoresBolsaDeTrabajo] (Nombre, StatusProveedor)
		values ( @Nombre, @StatusProveedor)
	end else
	begin
		update [Reclutamiento].[tblProveedoresBolsaDeTrabajo]
			set Nombre = @Nombre, StatusProveedor = @StatusProveedor
		where IDProveedorBolsaDeTrabajo = @IDProveedorBolsaDeTrabajo
	end;

END
GO
