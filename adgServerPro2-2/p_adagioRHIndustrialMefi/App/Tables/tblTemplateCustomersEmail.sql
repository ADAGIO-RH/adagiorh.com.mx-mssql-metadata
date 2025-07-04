USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblTemplateCustomersEmail](
	[IDCustomer] [int] NOT NULL,
	[BodyCustomer] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PixelesWidth] [int] NULL,
	[IsAnclado] [bit] NOT NULL,
	[Personalizado] [bit] NOT NULL,
	[IDTemplateNotificacion] [int] NOT NULL,
	[IDContainer] [int] NOT NULL,
 CONSTRAINT [Pk_ApptblTemplateCustomersEmail_IDCustomer] PRIMARY KEY CLUSTERED 
(
	[IDCustomer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblTemplateCustomersEmail]  WITH CHECK ADD  CONSTRAINT [FK_ApptblTemplateCustomersEmail_ApptblTemplateContainersEmail_IDContainer] FOREIGN KEY([IDContainer])
REFERENCES [App].[tblTemplateContainersEmail] ([IDContainer])
GO
ALTER TABLE [App].[tblTemplateCustomersEmail] CHECK CONSTRAINT [FK_ApptblTemplateCustomersEmail_ApptblTemplateContainersEmail_IDContainer]
GO
ALTER TABLE [App].[tblTemplateCustomersEmail]  WITH CHECK ADD  CONSTRAINT [FK_ApptblTemplateCustomersEmail_ApptblTemplateNotificaciones_IDTemplateNotificacion] FOREIGN KEY([IDTemplateNotificacion])
REFERENCES [App].[tblTemplateNotificaciones] ([IDTemplateNotificacion])
GO
ALTER TABLE [App].[tblTemplateCustomersEmail] CHECK CONSTRAINT [FK_ApptblTemplateCustomersEmail_ApptblTemplateNotificaciones_IDTemplateNotificacion]
GO
