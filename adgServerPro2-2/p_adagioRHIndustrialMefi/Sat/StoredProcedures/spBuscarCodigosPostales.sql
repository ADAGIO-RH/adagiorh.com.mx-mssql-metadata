USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Sat].[spBuscarCodigosPostales](
	@IDCodigoPostal int = 0,
	@IDEstado int = null,
	@IDMunicipio int = null,
	@IDLocalidad int = null,
	@CodigoPostal varchar(5)=null
)
AS
BEGIN
    
    select top 50
		IDCodigoPostal
		,coalesce(CodigoPostal, '') as CodigoPostal
		,IDEstado
		,IDMunicipio
		,isnull(IDLocalidad,0) as IDLocalidad 
    from [Sat].[tblCatCodigosPostales] with (nolock)
    where 
        ((IDEstado = @IDEstado) OR (@IDEstado is null) or (@IDEstado =0))
        and((IDMunicipio = @IDMunicipio) OR (@IDMunicipio is null) or (@IDMunicipio=0))
        and((IDLocalidad = @IDLocalidad) OR (@IDLocalidad is null) or (@IDLocalidad=0))
        and (IDCodigoPostal = @IDCodigoPostal OR isnull(@IDCodigoPostal,0) = 0)
        and (@CodigoPostal is null OR CodigoPostal like '%'+@CodigoPostal+'%')
END
GO
