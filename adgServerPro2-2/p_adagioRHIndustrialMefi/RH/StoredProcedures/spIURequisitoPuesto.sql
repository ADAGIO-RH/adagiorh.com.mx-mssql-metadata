USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIURequisitoPuesto](
	@IDRequisitoPuesto int = 0,
	@IDPuesto int,
	@IDTipoCaracteristica int, 
	@Requisito varchar(max),
	@Activo bit,
	@TipoValor varchar(255),
	@ValorEsperado varchar(max),
	@Data varchar(max),
	@IDUsuario int
) as

	set @Requisito = UPPER(@Requisito)
	if (ISNULL(@IDRequisitoPuesto, 0) = 0)
	begin
		insert RH.tblRequisitosPuestos(IDPuesto, IDTipoCaracteristica, Requisito, Activo, TipoValor, ValorEsperado, [Data])
		values(@IDPuesto, @IDTipoCaracteristica, @Requisito, @Activo, @TipoValor, @ValorEsperado, @Data)
	end else
	begin
		update RH.tblRequisitosPuestos
			set
				Requisito = @Requisito,
				Activo = @Activo,
				TipoValor = @TipoValor,
				ValorEsperado = @ValorEsperado,
				[Data] = @Data
		where IDRequisitoPuesto = @IDRequisitoPuesto
	end
GO
