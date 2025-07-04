USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Resguardo].[spAgregarValorAPropiedad](
	@IDPropiedad int,
	@NuevaOpcion varchar(255),
	@IDUsuario int
) as

	declare 
		@IDPropiedaOriginal int,
		@Varios varchar(max)
	;

	select 
		@IDPropiedaOriginal = ctaOriginal.IDPropiedad
	from [Resguardo].[tblCatPropiedadesArticulos] cta with (nolock)
		left join [Resguardo].[tblCatPropiedadesArticulos] ctaOriginal with (nolock) on cta.CopiadaDelIDPropiedad = ctaOriginal.IDPropiedad
	where cta.IDPropiedad = @IDPropiedad

	select @Varios = Varios
	from [Resguardo].[tblCatPropiedadesArticulos] cta with (nolock)
	where cta.IDPropiedad = @IDPropiedaOriginal

	declare @tempVarios as table(
		Valor varchar(255)
	)

	insert @tempVarios
	select Item
	from App.Split(@Varios, ',')

	if exists(select top 1 1 from @tempVarios where Valor = @NuevaOpcion)
	begin
		raiserror('Ya exista esta opción.', 16, 1)
		return 
	end

	insert @tempVarios
	values(UPPER(@NuevaOpcion))

	select 
		@Varios = STUFF(
			(select ','  + upper(ltrim(rtrim(Valor))) from @tempVarios order by Valor FOR XML PATH ('')) ,1,1,''
		)

	update [Resguardo].[tblCatPropiedadesArticulos]
		set Varios = @Varios
	where IDPropiedad = @IDPropiedaOriginal
GO
