USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spMoverPlaza](
	@IDPlaza int,
    @IDPlazaTarget int,
	@IDPosicionTarget int,
	@IDUsuario int
) as
	
    declare @jsonr varchar(max)
    select @jsonr=Configuraciones From rh.tblCatPlazas where IDPlaza=@IDPlaza
    declare @configuracion VARCHAR(max)   
 
    declare @tabla   as table (
        IDTipoConfiguracionPlaza varchar(200),
        Valor int,
        Descripcion varchar(200)
    )
    insert into @tabla
    SELECT *
        FROM OPENJSON ( @jsonr )  
        WITH (                               
              IDTipoConfiguracionPlaza VARCHAR(200)   '$.IDTipoConfiguracionPlaza',  
              Valor INT            '$.Valor'              ,
              Descripcion VARCHAR(200)   '$.Descripcion'
            )
 
 
    set @configuracion=(select 
        IDTipoConfiguracionPlaza,
        case when 
            IDTipoConfiguracionPlaza='PosicionJefe' then @IDPosicionTarget else Valor end as [Valor],           
        Descripcion
    From @tabla
    for JSON auto)

    

    update RH.tblCatPlazas set ParentId=@IDPlazaTarget  , Configuraciones=@configuracion
    where IDPlaza=@IDPlaza;


    update rh.tblCatPosiciones set ParentId =@IDPosicionTarget 
    where IDPlaza=@IDPlaza;
GO
