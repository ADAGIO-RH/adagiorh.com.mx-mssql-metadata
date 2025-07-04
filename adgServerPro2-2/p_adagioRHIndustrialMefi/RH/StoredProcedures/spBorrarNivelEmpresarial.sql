USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBorrarNivelEmpresarial](
    @IDNivelEmpresarial int,
    @ConfirmarEliminar bit=0,
    @IDUsuario int 	
) as 
	declare 
		@IDIdioma varchar(20)
	;

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')    

    create table #dtNiveles (
        Nivel  int IDENTITY(1,1) PRIMARY key
    )

    declare @dtPlazas as table  (
        RowNumber int,
        CodigoPlaza  [App].[SMName] ,
        Puesto varchar(max),
        Nivel int
    )

    declare @TotalNivelesAEliminar int 
                 
    insert into @dtPlazas
    SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), pla.Codigo  ,JSON_VALUE(tPuestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),IDNivelSalarial
    From rh.tblCatPlazas   pla
    INNER JOIN RH.tblCatPuestos tPuestos on tPuestos.IDPuesto=pla.IDPuesto
    WHERE IDNivelEmpresarial=@IDNivelEmpresarial

    if(exists(select top 1 1 from @dtPlazas))
    BEGIN        
        SELECT -1 IDTipoRespuesta, ( SELECT * FROM @dtPlazas FOR JSON AUTO) as Mensaje  ;          
    END
    ELSE 
    BEGIN                                      
        select 'Se ha eliminado el nivel empresarial correctamente.' as [Mensaje],  0 IDTipoRespuesta                                                
        DELETE FROM RH.tblCatNivelesEmpresariales where 
            IDNivelEmpresarial=@IDNivelEmpresarial                                
    END
GO
