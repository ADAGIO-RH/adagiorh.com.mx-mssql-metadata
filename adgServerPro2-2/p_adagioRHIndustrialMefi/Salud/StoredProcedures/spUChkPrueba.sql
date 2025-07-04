USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Salud].[spUChkPrueba](
	@IDPrueba int 
	,@Type varchar(20)
	,@Valor bit
	,@IDUsuario int
) as

	if (@Type = 'liberada') -- Libera la prueba
	begin
		update [Salud].[tblPruebas]
			set Liberado = @Valor
		where IDPrueba = @IDPrueba
	end else
	if (@Type = 'temperatura') -- Habilita la captura de temperatura
	begin
		update [Salud].[tblPruebas]
			set RevisionTemperatura = @Valor
		where IDPrueba = @IDPrueba
	end
GO
