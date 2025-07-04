USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aneudy Abreu
-- Create date: 2022-12-05
-- Description:	Busca el valor de una preferencia de usuario
-- =============================================
CREATE FUNCTION [App].[fnGetConfiguracionGeneral](
	@IDConfiguracion varchar(255),
	@IDUsuario int,
	@Default nvarchar(max)= null
)
RETURNS nvarchar(max)
AS
BEGIN
	declare 
		@Value nvarchar(max)
	;

	select @Value = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = @IDConfiguracion
		
	set @Value = case when @Value is null and @Default is not null then @Default else @Value end

	return @Value
END
GO
