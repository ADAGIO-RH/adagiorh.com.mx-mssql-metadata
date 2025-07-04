USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEstatusSolicitudPosiciones](
	[IDEstatusSolicitudPosiciones] [int] IDENTITY(1,1) NOT NULL,
	[IDSolicitudPosiciones] [int] NULL,
	[IDEstatus] [int] NULL,
	[IDUsuario] [int] NULL,
	[FechaReg] [datetime] NULL,
 CONSTRAINT [Pk_tblEstatusSolicitudPosiciones_IDEstatusSolicitudPosiciones] PRIMARY KEY CLUSTERED 
(
	[IDEstatusSolicitudPosiciones] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblEstatusSolicitudPosiciones]  WITH CHECK ADD  CONSTRAINT [FK_tblEstatusSolicitudPosiciones_RHtblSolicitudPosiciones_IDSolicitudPosiciones] FOREIGN KEY([IDSolicitudPosiciones])
REFERENCES [RH].[tblSolicitudPosiciones] ([IDSolicitudPosiciones])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblEstatusSolicitudPosiciones] CHECK CONSTRAINT [FK_tblEstatusSolicitudPosiciones_RHtblSolicitudPosiciones_IDSolicitudPosiciones]
GO
