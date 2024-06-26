USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select *
--from Seguridad.TblUsuarios


--select *
--from [Seguridad].[TblUsuariosKeysActivacion]

create proc [Seguridad].[spActivarCuenta](
    @key nvarchar(max) 
)as
declare 
--@key nvarchar(max) = 'UWxRUXpuOHk1MUxSR0tzblMzVlZHcWdXam5FUUJra0dFWHc2MDBVOVlGdz06cG9sYnJhdTdAZ21haWwuY29tOjU='
    @IDUsuario int = 0;


    select @IDUsuario=isnull(IDUsuario,0)	
    from [Seguridad].[TblUsuariosKeysActivacion] 
    where ActivationKey = @key and AvaibleUntil >= cast(Getdate() as date)
    and Activo = 1

    if (@IDUsuario = 0)
    begin
	   raiserror('La clave de activación no es válida!',16,0)
	   return;
    end;

    update Seguridad.TblUsuarios
    set Activo=1
    where IDUsuario=@IDUsuario

    update [Seguridad].[TblUsuariosKeysActivacion] 
    set Activo = 0
    where ActivationKey = @key
GO
