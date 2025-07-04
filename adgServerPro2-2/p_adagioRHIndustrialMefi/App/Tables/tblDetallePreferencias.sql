USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblDetallePreferencias](
	[IDDetallePreferencia] [int] IDENTITY(1,1) NOT NULL,
	[IDPreferencia] [int] NOT NULL,
	[IDTipoPreferencia] [int] NOT NULL,
	[Valor] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_tblDetallePreferencias_IDDetallePreferencia] PRIMARY KEY CLUSTERED 
(
	[IDDetallePreferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblDetallePreferencias]  WITH CHECK ADD  CONSTRAINT [Fk_tblDetallePreferencias_IDPreferencia] FOREIGN KEY([IDPreferencia])
REFERENCES [App].[tblPreferencias] ([IDPreferencia])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblDetallePreferencias] CHECK CONSTRAINT [Fk_tblDetallePreferencias_IDPreferencia]
GO
ALTER TABLE [App].[tblDetallePreferencias]  WITH CHECK ADD  CONSTRAINT [Fk_tblDetallePreferencias_IDTipoPreferencia] FOREIGN KEY([IDTipoPreferencia])
REFERENCES [App].[tblCatTiposPreferencias] ([IDTipoPreferencia])
GO
ALTER TABLE [App].[tblDetallePreferencias] CHECK CONSTRAINT [Fk_tblDetallePreferencias_IDTipoPreferencia]
GO
