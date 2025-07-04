USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[RH].[spBorrarTabuladorSalarialByNivel]
CREATE proc [RH].[spUEstatusTabuladorSalarial](
    @IDNivelSalarial int,    
    @Estatus int ,
    @ConfirmarEliminar bit=0,
    @IDUsuario int 	
) as 
	declare  @IDIdioma varchar(20);
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
        
    declare @dtPlazas as table  (
        RowNumber int,
        CodigoPlaza  [App].[SMName] ,
        Puesto varchar(max),
        Nivel int
    )
    
         
    insert into @dtPlazas
    SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), pla.Codigo  ,JSON_VALUE(tPuestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),IDNivelSalarial
    From rh.tblCatPlazas   pla
    INNER JOIN RH.tblCatPuestos tPuestos on tPuestos.IDPuesto=pla.IDPuesto
    WHERE pla.IDNivelSalarial=@IDNivelSalarial

    if(exists(select top 1 1 from @dtPlazas))
    BEGIN        
        select -1 IDTipoRespuesta, ( SELECT * FROM @dtPlazas FOR JSON AUTO) as Mensaje ;          
    END
    ELSE 
    BEGIN                                     
        select 'Se han deshabilitado el nivel correctamente.' as [Mensaje], 
                        0 IDTipoRespuesta                                                
        update rh.tblTabuladorSalarial 
        set Estatus=@Estatus
        where  IDNivelSalarial=@IDNivelSalarial                            
                 
    END
GO
