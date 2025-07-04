USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===============================================
 --Tipo Referencia
 -- 0: Cuestionarios Default
 -- 1: IDPrueba
 -- 2: IDPruebaEmpleado
--===============================================
CREATE PROCEDURE [Salud].[spBuscarCuestionarioPrueba] --0, 1, 3,1
(
	@IDCuestionario int = 0,
	@TipoReferencia int = 0,
	@IDReferencia int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @ConfiguracioSemaforo VARCHAR(MAX)

	if (@TipoReferencia = 2)
	begin
		select top 1 @ConfiguracioSemaforo = ce.ConfiguracioSemaforo
		from Salud.tblCuestionariosEmpleados ce
		where ce.IDCuestionarioEmpleado = @IDReferencia
	end

	Select 
		IDCuestionario
		,Nombre
		,Descripcion
		,TipoReferencia = isnull(TipoReferencia,0)
		,IDReferencia = isnull(IDReferencia,0)
		,isDefault = isnull(isDefault,0)
		,isnull(FechaCreacion,getdate()) as FechaCreacion
		,@ConfiguracioSemaforo as ConfiguracioSemaforo
	from Salud.tblCuestionarios with (nolock)
	where --(IDCuestionario = @IDCuestionario) or (@IDCuestionario = 0)
		(IDCuestionario = @IDCuestionario) or ( 
		  (TipoReferencia = @TipoReferencia /* or @TipoReferencia = 0 */) and 
		  (IDReferencia = @IDReferencia /* or @IDReferencia = 0 */) )
END
GO
