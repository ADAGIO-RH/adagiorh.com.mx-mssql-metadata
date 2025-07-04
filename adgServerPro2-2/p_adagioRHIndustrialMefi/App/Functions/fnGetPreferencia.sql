USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aneudy Abreu
-- Create date: 2022-04-012
-- Description:	Busca el valor de una preferencia de usuario
-- =============================================
CREATE FUNCTION App.fnGetPreferencia(
	@TipoPreferencia varchar(255),
	@IDUsuario int,
	@Default nvarchar(max)= null
)
RETURNS nvarchar(max)
AS
BEGIN
		declare 
			@Value nvarchar(max)
		;

		select @Value=dp.Valor
		from Seguridad.tblUsuarios u with (nolock)
			inner join App.tblPreferencias p with (nolock) on u.IDPreferencia = p.IDPreferencia
			inner join App.tblDetallePreferencias dp with (nolock) on dp.IDPreferencia = p.IDPreferencia
			inner join App.tblCatTiposPreferencias tp with (nolock) on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = @TipoPreferencia
		
		set @Value = case when @Value is null and @Default is not null then @Default else @Value end

		 set @Value = case when @Value = '' and @Default is not null then @Default else @Value end

		return @Value
END
GO
